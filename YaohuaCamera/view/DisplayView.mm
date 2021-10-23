//
//  DisplayView.m
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
int monthid;
#import "DisplayView.h"
//#import "CallBackHandle.h"
#import <FunSDK/FunSDK.h>
#import <FunSDK/netsdk.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAssetChangeRequest.h>
#import <AVFoundation/AVFoundation.h>
#import "Recode.h"
#include "BasicFun.h"

#import "RET.h"

@interface DisplayView()

@property(nonatomic,copy) NSString * sn;
@property(nonatomic,copy) NSString * pwd;
@property int streamType;
@property bool statusPause;
@property NSDateComponents* startTime;
@property NSDateComponents* endTime;
@property FUN_HANDLE lPlayHandle;
@property FUN_HANDLE lTalkHandle;
@property NSString * file;
@property Recode * record;
@property NSTimer * timer;
@property UI_HANDLE hWnd;
@property void * pWnd;
@property bool online;
@property bool loginFromHistory;


@end

@implementation DisplayView
+(Class) layerClass{
    return [CAEAGLLayer class];
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (self) {
        self.pWnd = (__bridge void *) self;
        self.hWnd = FUN_RegWnd(_pWnd);
    }
}
-(void)load:(NSString *)sn pwd:(NSString*) pwd{
    self.sn = sn;
    self.pwd = pwd;
}
-(void)connect{
    if (!self.isConnected) {
        FUN_DevLogin(self.hWnd,[self.sn UTF8String],"admin", [self.pwd UTF8String], 0);
        FUN_DevSetLocalPwd([self.sn UTF8String], "admin", [self.pwd UTF8String]);//2018.07.06雄迈
        [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONNECT_START object:self.sn];
    }
}
-(void) disconnect{
    self.isConnected = false;
    [self stop];
    FUN_DevLogout(self.hWnd,[self.sn UTF8String]);
}
-(void)getStatus{
    [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONNECT_START object:self.sn];
    FUN_SysGetDevState(self.hWnd, [self.sn UTF8String]);
}

-(void)play:(int) streamType{
    self.startTime = nil;
    self.endTime = nil;
    self.streamType = streamType;
    if (!self.isConnected) {
        if (!self.online) {
            [self getStatus];
        }else{
            [self connect];
        }
    }else{
        if (self.statusPause) {
            [self pause:0];
            NSLog(@"恢复播放 :%@, handler :%d",streamType == 0 ? @"高清":@"标清",self.lPlayHandle);
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_LOADING object:self.sn];
            [self stop];
            self.lPlayHandle = FUN_MediaRealPlay(self.hWnd,[self.sn UTF8String],0, streamType, (__bridge LP_WND_OBJ)self,0);
            NSLog(@"播放 :%@, handler :%d",streamType == 0 ? @"高清":@"标清",self.lPlayHandle);
        }
    }
}
-(void) pause :(int) pauseOrResume{
    if ([self isPlaying]) {
        FUN_MediaPause(self.lPlayHandle, pauseOrResume);
        self.statusPause = pauseOrResume == 1;
    }
}

-(void)seek:(int) time{
    if (self.statusPause) {
        [self pause:0];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RET_LOADING object:self.sn];
    FUN_MediaSeekToTime(self.lPlayHandle, -1, time, 0);
}

-(void)replay:(NSDateComponents *)startTime end:(NSDateComponents *)endTime{
    self.startTime = startTime;
    self.endTime = endTime;
    if (!self.isConnected) {
        if (!self.online) {
            [self getStatus];
        }else{
            [self connect];
        }
    }else{
        if (self.statusPause) {
            [self pause:0];
            NSLog(@"恢复回放 , handler :%d",self.lPlayHandle);
        }else{
             [[NSNotificationCenter defaultCenter] postNotificationName:RET_LOADING object:self.sn];
            H264_DVR_FINDINFO findInfo;         //查询条件结构体
            memset(&findInfo, 0, sizeof(findInfo)); //清零
            findInfo.nChannelN0 = 0;//通道号
            findInfo.nFileType  = 0;//文件类型
            
            findInfo.endTime    = BasicFun::TRH264_DVR_TIME((int) endTime.year, (int) endTime.month,(int) endTime.day, (int) endTime.hour, (int) endTime.minute,(int) endTime.second);
            findInfo.startTime = BasicFun::TRH264_DVR_TIME((int) startTime.year, (int) startTime.month,(int) startTime.day,(int) startTime.hour, (int) startTime.minute, (int) startTime.second);
            [self stop];
             self.lPlayHandle = FUN_MediaNetRecordPlayByTime(self.hWnd,[self.sn UTF8String],&findInfo,(__bridge LP_WND_OBJ) self, 0);
            if(self.timer != nil){
                [self.timer invalidate];
            }
            self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:NSSelectorFromString(@"tick:") userInfo:nil repeats:YES];
        }
    }
}

- (void) tick:(id)userinfo{
    if (self.lPlayHandle != 0) {
        long current = (long)FUN_MediaGetCurTime(_lPlayHandle);
        [[NSNotificationCenter defaultCenter] postNotificationName:RET_TIMER object:[NSNumber numberWithLong:current]];
    }
}
-(void)stop{
    if ([self isPlaying]) {
        if (self.timer != nil) {
            [self.timer invalidate];
            self.timer = nil;
        }
        [self talk:false];
        FUN_MediaStop(self.lPlayHandle, NULL);
        self.statusPause = false;
        self.lPlayHandle = 0;
    }
}

-(void)sound:(bool)on{
    if (on) {
        FUN_MediaSetSound(_lPlayHandle, 100,0);
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }else{
        FUN_MediaSetSound(_lPlayHandle, -1,0);
    }
}
-(void)record:(bool)on{
    if (on) {
        NSString * path = [self getMP4FilePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:path]){
            [fm createDirectoryAtPath:path withIntermediateDirectories:TRUE attributes:nil error:nil];
        }
        self.file = [[path stringByAppendingFormat:@"/%@_%02d.mp4",[self getSystemTimeString],0] copy];
        
        FUN_MediaStartRecord(_lPlayHandle, [self.file UTF8String]);
    }else{
        FUN_MediaStopRecord(_lPlayHandle);
        PHPhotoLibrary * lib = [PHPhotoLibrary sharedPhotoLibrary];
        if (self.file == nil) {
            return;
        }
        [lib performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:self.file]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_RECORD object:[NSNumber numberWithBool:success]];
        }];
    }
}


//MARK: 时间串
-(NSString*)getSystemTimeString{
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
    NSString *dateString = [dateFormatter stringFromDate:nowDate];
    return dateString;
}

- (NSString*)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"image"];
}
- (NSString*)getMP4FilePath{
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePath objectAtIndex:0];
    return [documentsDirectory  stringByAppendingPathComponent:@"MP4"];
}
-(void)shot{
    NSString *dateString = [self getSystemTimeString];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory ;
    if (![fm fileExistsAtPath: (directory = [self dataFilePath])]) {
        [fm createDirectoryAtPath:[self dataFilePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString * pictureFilePath = [directory stringByAppendingFormat:@"/%@.jpg",dateString];
    
    FUN_MediaSnapImage(_lPlayHandle,[pictureFilePath UTF8String],0);
}
-(void)talk:(bool)on{
    
    if (on) {
        
        if (self.record == nil) {
            self.record = [[Recode alloc] init:[self.sn UTF8String]];
        }else{
            [self.record stop];
        }
        self.lTalkHandle = FUN_DevStarTalk(self.hWnd,[self.sn UTF8String]);
        
        [self.record start];
    }else{
        [self.record stop];
        FUN_DevStopTalk(self.lTalkHandle);
    }
}
-(bool)isPlaying{
    return self.lPlayHandle > 0 && self.lPlayHandle != 65566;
}

-(void)monthData{
    NSDateComponents * calendar = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSString * cmd = [NSString stringWithFormat:@"{\"Name\":\"OPSCalendar\",\"OPSCalendar\": {\"Event\":   \"*\",\"FileType\": \"h264\",\"Month\":  %ld ,\"Rev\":   \"\",\"Year\": %ld},\"SessionID\":   \"0x00000001\"}",(long)[calendar month],(long)[calendar year]];
    
    FUN_DevCmdGeneral(self.hWnd,[self.sn UTF8String],2026, "OPSCalendar",0, 5000,strdup([cmd UTF8String]));
    
}

-(void) autoType{
    FUN_MediaSetPlaySize(self.lPlayHandle, 2);
}

-(void)search:(NSDateComponents *)startTime end:(NSDateComponents *)endTime {
    
    if (!self.isConnected) {
        self.loginFromHistory = true;
        self.startTime = startTime;
        self.endTime = endTime;
        if (self.online) {
            [self connect];
        }else{
            //[self getStatus];
        }
    }else{
        self.loginFromHistory = false;
        SDK_SearchByTime info;
        
        //开内存
        memset(&info, 0, sizeof(info));
        info.nHighChannel = 0;
        info.nLowChannel = 0;
        info.nFileType = 0;
        info.iSync = 0;
        
        
        
        info.stBeginTime.year = (int)[startTime year];
        info.stBeginTime.month = (int)[startTime month];
        info.stBeginTime.day = (int)[startTime day];
        info.stBeginTime.hour =  (int)[startTime hour];
        info.stBeginTime.minute =  (int)[startTime minute];
        info.stBeginTime.second =  (int)[startTime second];
        
        //结束时间
        info.stEndTime.year = (int)[endTime year];
        info.stEndTime.month = (int)[endTime month];
        info.stEndTime.day = (int)[endTime day];
        info.stEndTime.hour =  (int)[endTime hour];
        info.stEndTime.minute = (int) [endTime minute];
        info.stEndTime.second =  (int)[endTime second];
        
        
        int chn = 0;
        if (chn > 31) {
            info.nHighChannel = (1 << (chn - 32));
        } else {
            info.nLowChannel = (1 << chn);
        }
        FUN_DevFindFileByTime(self.hWnd, [self.sn UTF8String], &info);
         [[NSNotificationCenter defaultCenter] postNotificationName:RET_SEARCHING object:self.sn];
    }
   
}
-(NSString *) picPath {

    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory ;
    if (![fm fileExistsAtPath: (directory = [self dataFilePath])]) {
        [fm createDirectoryAtPath:[self dataFilePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return  [directory stringByAppendingFormat:@"/%@.jpg",self.sn];
}


-(void)OnFunSDKResult:(NSNumber *)param{
    NSInteger data = [param integerValue];
    MsgContent *msg = (MsgContent *)data;
    NSLog(@"OnFunSDKResult %d,p1:%d,p2:%d,p3:%d",msg->id,msg->param1,msg->param2,msg->param3);
    switch (msg->id) {
        case EMSG_SYS_GET_DEV_STATE:
        {
            NSLog(@"EMSG_SYS_GET_DEV_STATE %d,p1:%d,p2:%d,p3:%d",msg->id,msg->param1,msg->param2,msg->param3);
            
            self.online = msg->param1 > 0;
            if (!self.online) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_OFFLINE object:self.sn];
            }else{
                [self connect];
            }
        }
            
            break;
        case EMSG_DEV_LOGIN:
        {
            NSLog(@"EMSG_DEV_LOGIN %d,p1:%d,p2:%d,p3:%d",msg->id,msg->param1,msg->param2,msg->param3);
            self.isConnected = msg->param1 == EE_OK;
            if (!self.isConnected) {
                if (msg->param1 == EE_DVR_PASSWORD_NOT_VALID) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_PWD_ERROR object:self.sn];
                    self.online = false;
                }else if (msg->param1 == EE_DVR_USER_LOCKED) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_USER_LOCKED object:self.sn];
                    self.online = false;
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_TIME_OUT object:self.sn];
                    self.online = false;
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONNECT object:self.sn];
                FUN_DevOption(self.hWnd,[self.sn UTF8String], EDA_DEV_OPEN_TANSPORT_COM,  0,8, RS232, self.hWnd,0,"");
                FUN_DevOption(self.hWnd,[self.sn UTF8String], EDA_DEV_OPEN_TANSPORT_COM,  0,8, RS232, self.hWnd,0,"");
                FUN_DevOption(self.hWnd,[self.sn UTF8String], EDA_DEV_OPEN_TANSPORT_COM,  0,8, RS232, self.hWnd,0,"");
                if (self.timeArray == nil) {
                    [self monthData];                  
//                    char pInparm[512] = {0};
//                    sprintf(pInparm, "{\"Name\" : \"OPCompressPic\", \"OPCompressPic\": {\"Width\" : 700,\"Height\" :486,  \"IsGeo\" :1, \"PicName\" :\"%s\"},\"SessionID\" : \"0x00000002\"}",[[self.sn stringByAppendingString:@".jpg"] UTF8String]);
//                    FUN_DevSearchPic(self.hWnd, [self.sn UTF8String], 1448, 30000, 2000, pInparm, (int)strlen(pInparm), 10,  -1, [[self picPath] UTF8String], 0);
                }
//                FUN_DevOption(self.hWnd,[self.sn UTF8String], EDA_DEV_OPEN_TANSPORT_COM,  0,8, RS232, self.hWnd,0,"");
                
                
                
                if (self.startTime != nil && self.endTime != nil) {
                    if (self.loginFromHistory) {
                        [self search:self.startTime end:self.endTime];
                    }else{
                        [self replay:self.startTime end:self.endTime];
                    }
                    
                }else{
                    [self play:self.streamType];
                }
            }
        }
            break;
        case EMSG_DEV_OPTION:
        {
            if (msg->param1 == -11502) {
                FUN_DevOption(self.hWnd,[self.sn UTF8String], EDA_DEV_OPEN_TANSPORT_COM,  0,8, RS232, self.hWnd,0,"");
            }
        }
            break;
            //串口收到数据
        case EMSG_DEV_ON_TRANSPORT_COM_DATA:
            
        {
            NSLog(@"收到: 【%s】",msg->pObject);
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONFIG object:[NSString stringWithUTF8String:msg->pObject]];
        }
            
            break;
        case EMSG_START_PLAY:
        {
            NSLog(@"EMSG_START_PLAY %d,p1:%d,p2:%d,DSS:%d",msg->id,msg->param1,msg->param2,msg->param3);
            
            if (msg->param1 == EE_TPS_NOT_SUP_MAIN ||  msg->param1 == EE_DSS_NOT_SUP_MAIN) {
                [self play:1];
            }
            if (msg->param1 == EE_DVR_SDK_TIMEOUT || msg->param1 == -100000) {
                [self stop];
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_TIME_OUT object:self.sn];
            }
            if (msg->param1 == EE_DVR_USER_LOCKED || msg->param1 == -110303) {
                [self stop];
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_USER_LOCKED object:self.sn];
            }
            if (msg->param3 == 3)//dss
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_DSS object:self.sn];
            }
            if (msg->param3 == 5)//RPS
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_RPS object:self.sn];
            }
//            if (msg->param1 == EE_OK) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:RET_PLAY object:self.sn];
//            }
            
        }
            break;
        case EMSG_ON_PLAY_BUFFER_BEGIN:
            {
                 [[NSNotificationCenter defaultCenter] postNotificationName:RET_CACHE object:self.sn];
            }
            break;
        case EMSG_SEEK_TO_TIME:
            {
                if (msg->param1 == EE_MNETSDK_DEV_IS_OFFLINE) {
                    [self disconnect];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_DISCONNECT object:self.sn];
                }
                
                if (msg->param1 == EE_DVR_SDK_TIMEOUT) {
                    [self stop];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_TIME_OUT object:self.sn];
                }
                if (msg->param1 == EE_DVR_USER_LOCKED) {
                    [self stop];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_USER_LOCKED object:self.sn];
                }
            }
            break;
        case EMSG_ON_PLAY_BUFFER_END:
        {
            if (msg->param1 == EE_OK) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_PLAY object:self.sn];
            }
        }
            break;
        case EMSG_ON_PLAY_END:
            {
                [self stop];
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_END object:self.sn];
            }
            break;
        case EMSG_PAUSE_PLAY:
        {
            NSLog(@"EMSG_PAUSE_PLAY %d,p1:%d,p2:%d,p3:%d",msg->id,msg->param1,msg->param2,msg->param3);
            
            
            //正在播放
            if (msg->param1 == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_PLAY object:self.sn];
            }
            
        }
            break;
            
        case EMSG_ON_PLAY_ERROR:
        case EMSG_ON_MEDIA_NET_DISCONNECT:
        {
//            [self disconnect];
//            [[NSNotificationCenter defaultCenter] postNotificationName:RET_DISCONNECT object:self.sn];
        }
            break;
        case EMSG_DEV_ON_RECONNECT:
        {
            self.isConnected = true;
        }
            break;
        case EMSG_DEV_ON_DISCONNECT:
        {
            [self disconnect];
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_DISCONNECT object:self.sn];
        }
            break;
            
        case EMSG_DEV_FIND_FILE_BY_TIME:
        {
            NSLog(@"EMSG_DEV_FIND_FILE_BY_TIME: %d",msg->param1);
            // 没有找到录像
            if (msg->param1 < 0) {
                printf("没有录像");
            }
            // 找到录像
            else {
                if (self.timeArray == nil) {
                    self.timeArray = [NSMutableArray array];
                }else{
                    [self.timeArray removeAllObjects];
                }
                
                
                SDK_SearchByTimeResult* pResult = (SDK_SearchByTimeResult*)msg->pObject;
                
                SDK_SearchByTimeInfo* backData = &pResult->ByTimeInfo[0];
                
                for (int i = 0; i < 720; i++) {
                    ByteRecordType* pType =
                    (ByteRecordType*)(&backData->cRecordBitMap[i]);
                    
                    [self createVideoDataWithType:[self getType:pType->t0]
                                     andStartTime:(i * 120)
                                       andEndTime:((i * 120) + 60)
                                          toArray:self.timeArray];
                    [self createVideoDataWithType:[self getType:pType->t1]
                                     andStartTime:((i * 120) + 60)
                                       andEndTime:(i + 1) * 120
                                          toArray:self.timeArray];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_FIND object:self.sn];
            }
        }
            break;
            
        case EMSG_DEV_CMD_EN:
        {
            if (monthid == 0) {
                monthid = 1;
            }else{
                monthid = 0;
            }
            printf("取报警日期%d",monthid);
            NSError *jsonError;
            if(msg->pObject){
                NSString * data = [NSString stringWithUTF8String:msg->pObject];
                printf("month data %s",msg->pObject);
                
                if (data != nil) {
                    NSData *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonError];
                    NSArray<NSNumber*> * nums = json[@"OPSCalendar"][@"Mask"];
                    //[self intToBinary:[num intValue]];
                    if (monthid == 1) {
                        _dateArray = [NSMutableArray array];
                    }
                    //gather current calendar
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    //gather date components from date
                    NSDateComponents *dateComponents = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
                    //set date components
                    if (monthid == 0) {
                        [dateComponents setYear:[dateComponents year] - 1];
                    }
                    [dateComponents setHour:0];
                    [dateComponents setMinute:0];
                    [dateComponents setSecond:0];
                    //save date relative from date
                    int month = 1;
                    for (NSNumber * num in nums) {
                        [dateComponents setMonth:month++];
                        for (int i = 0; i < 31; ++i) {
                            if (0 != (num.intValue & (1 << i))) {
                                [dateComponents setDay:i+1];
                                [_dateArray addObject:[NSNumber numberWithDouble:[[calendar dateFromComponents:dateComponents] timeIntervalSince1970]]];
                                //    这个排序方法没有返回值,它直接操作数组的元素,将源数组排序好
                                [_dateArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                    if ([obj1 integerValue] < [obj2 integerValue]) {
                                        return NSOrderedDescending;
                                    } else if ([obj1 integerValue] > [obj2 integerValue]) {
                                        return NSOrderedAscending;
                                    }
                                    return NSOrderedSame;
                                    //        return [obj1 integerValue] > [obj2 integerValue];//简写方式
                                }];
                                
                            }
                        }
                    }
                }
            }
        }
            break;
            
        case EMSG_SAVE_IMAGE_FILE:
            {
                boolean success = msg->param1 == EE_OK;
                if (success) {
                    NSString * pictureFilePath = [NSString stringWithUTF8String:msg->szStr];
                    UIImage * image = [UIImage imageWithContentsOfFile:pictureFilePath];
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_SHOT object:[NSNumber numberWithBool:success]];
            }
            break;
        default:
            break;
    }
}



- (void)createVideoDataWithType:(enum Video_Type)type
                   andStartTime:(int)ss
                     andEndTime:(int)es
                        toArray:(NSMutableArray*)array
{
    
    FileData  *data = [[FileData alloc] init];
    data.stBeginTime = ss;
    data.stEndTime = es;
    
    if (type!=TYPE_NONE) {
        [array addObject:data];
    }
}

- (Video_Type)getType:(int)sdkType
{
    switch (sdkType) {
        case 0:
            return TYPE_NONE;
        case 1:
            return TYPE_NORMAL;
            break;
        case 2:
            return TYPE_ALARM;
            break;
        case 3:
            return TYPE_DETECTION;
            break;
        case 4:
            return TYPE_NORMAL;
            break;
        case 5:
            return TYPE_HAND;
            break;
        default:
            return TYPE_NORMAL;
            break;
    }
    return TYPE_NORMAL;
}

- (NSString *)intToBinary:(int)intValue{
    int totalBits = 32, // Total bits
    binaryDigit = totalBits; // Which digit are we processing   // C array - storage plus one for null
    char ndigit[totalBits + 1];
    while (binaryDigit-- > 0)
    {
        // Set digit in array based on rightmost bit
        ndigit[binaryDigit] = (intValue & 1) ? '1' : '0';
        // Shift incoming value one to right
        intValue >>= 1;  }   // Append null
    ndigit[totalBits] = 0;
    // Return the binary string
    return [NSString stringWithUTF8String:ndigit];
}


@end
