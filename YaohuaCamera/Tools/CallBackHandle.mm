//
//  CallBackHandle.c
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
#import <FunSDK/FunSDK.h>
#import "CallBackHandle.h"
#import "RET.h"
#import <UIKit/UIKit.h>
#import "SDK.h"

typedef struct ByteRecordType
{
    unsigned char t0:4;
    unsigned char t1:4;
}ByteRecordType;

@implementation CallBackHandle
@synthesize beep;
@synthesize dateEnd;
@synthesize date;
@synthesize outLevel;

NSMutableArray* _timeArray;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pWnd = (__bridge void *) self;

        self.hWnd = FUN_RegWnd(_pWnd);
    }
    return self;
}
-(void)OnFunSDKResult:(NSNumber *)param{
    NSInteger data = [param integerValue];
    MsgContent *msg = (MsgContent *)data;
    bool success;
    NSLog(@"=========================return %d======param1 %d=========================",msg->id,msg->param1);
    switch (msg->id) {
            //快速配置
        case EMSG_DEV_AP_CONFIG:
            
            if (msg->param1 > 0) {
                SDK_CONFIG_NET_COMMON_V2  device = *(SDK_CONFIG_NET_COMMON_V2*)(msg->pObject);
                NSLog(@"快速配置成功%s",device.sSn);
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_QUICKCONFIG_SUCCESS object:[CallBackHandle ToNSStr:device.sSn]];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_QUICKCONFIG_SUCCESS object:nil];
                NSLog(@"快速配置失败");
            }
            
            break;
            //设备搜索
        case EMSG_DEV_SEARCH_DEVICES:
            if (msg->param1 > 0) {

                struct SDK_CONFIG_NET_COMMON_V2* netCommonBuf = (struct SDK_CONFIG_NET_COMMON_V2*)msg->pObject;
                for (int i = 0; i < msg->param2; ++i) {
                    
                    NSString* sn = [NSString stringWithUTF8String:netCommonBuf[i].sSn];

                    NSString* ip = [NSString stringWithFormat:@"%d.%d.%d.%d", netCommonBuf[i].HostIP.c[0], netCommonBuf[i].HostIP.c[1], netCommonBuf[i].HostIP.c[2], netCommonBuf[i].HostIP.c[3]];
//                    int  port = netCommonBuf[i].TCPPort;
//                    NSString* sid = [NSString stringWithUTF8String:netCommonBuf[i].HostName];
//                    int deviceType = netCommonBuf[i].DeviceType;
                    NSLog(@"Search[%@],ip[%@]", sn,ip);
                }

            }else{
                NSLog(@"局域网中没有设备");
            }
            break;
            //登陆
        case EMSG_DEV_LOGIN:
            success = msg->param1 >= 0;
            self.isConnected = msg->param1 >= 0;
            if (msg->param1 == EE_DVR_PASSWORD_NOT_VALID) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_PWD_ERROR object: self.sn];
                NSLog(@"密码错误");
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONNECT object: [NSNumber numberWithBool:success]];
                NSLog(@"登陆%@",success ? @"成功" : @"失败");
            }
            break;
            //播放结束
        case EMSG_MEDIA_PLAY_DESTORY:
        case EMSG_ON_PLAY_END:
        case EMSG_ON_PLAY_ERROR:
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_END object:self.sn];
            break;
        case EMSG_DEV_START_TALK:
            if (msg->param1 <0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_DEBUG object:[NSNumber numberWithInt:msg->param1]];
            }
            NSLog(@"对讲%@",msg->param1 >= 0 ? @"成功" : @"失败");
            break;
        case EMSG_START_PLAY:
            success = msg->param1 >= 0;
            //超时
            if (msg->param1 == -10005) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_TIME_OUT object:nil];
                //转发不支持高清
            }else if (msg->param1 == -210009){
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_PLAY_1 object:self.sn];
                //播放结果
            }else{
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_PLAY object:[NSNumber numberWithBool:success]];
                
            }
            NSLog(@"播放%d,DSS %d",success,msg->param3);
            break;
            //        case EMSG_ON_PLAY_BUFFER_END:
            //            success = msg->param1 >= 0;
            //            [[NSNotificationCenter defaultCenter] postNotificationName:RET_PLAY object:[NSNumber numberWithBool:success]];
            break;
            //截图
                    //缓存
        case EMSG_ON_PLAY_BUFFER_BEGIN:
            success = msg->param1 == EE_OK;
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_CACHE object:[NSNumber numberWithBool:success]];
            }
            //透传
        case EMSG_DEV_OPTION:
            
            break;
            //串口收到数据
        case EMSG_DEV_ON_TRANSPORT_COM_DATA:
            NSLog(@"串口: 【%s】",msg->pObject);
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONFIG object:[NSString stringWithUTF8String:msg->pObject]];
            break;
        case EMSG_STOP_PLAY:
            break;
        case EMSG_ON_PLAY_INFO:
            
            break;
            //修改密码
        case EMSG_SYS_PSW_CHANGE:

            break;
        case EMSG_DEV_FIND_FILE_BY_TIME:
//            // 没有找到录像
//            if (msg->param1 < 0) {
//                printf("没有录像");
//                
//            }
//            // 找到录像
//            else {
//                [_timeArray removeAllObjects];
//                
//                SDK_SearchByTimeResult* pResult = (SDK_SearchByTimeResult*)msg->pObject;
//                
//                SDK_SearchByTimeInfo* backData = &pResult->ByTimeInfo[0];
//                
//                for (int i = 0; i < 720; i++) {
//                    ByteRecordType* pType =
//                    (ByteRecordType*)(&backData->cRecordBitMap[i]);
//                    
//                    [self createVideoDataWithType:[self getType:pType->t0]
//                                     andStartTime:(i * 120)
//                                       andEndTime:((i * 120) + 60)
//                                          toArray:_timeArray];
//                    [self createVideoDataWithType:[self getType:pType->t1]
//                                     andStartTime:((i * 120) + 60)
//                                       andEndTime:(i + 1) * 120
//                                          toArray:_timeArray];
//                }
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:RET_FIND object:_timeArray];
//                
//            }
            
            break;
            //注册推送
        case EMSG_MC_LinkDev:
            if (msg->param1 < 0) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_LINK object:[NSNumber numberWithBool:false]];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_LINK object:[NSNumber numberWithBool:true]];
            }
            break;
            //解除推送
        case EMSG_MC_UnlinkDev:
            if (msg->param1 < 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_UN_LINK object:[NSNumber numberWithBool:false]];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_UN_LINK object:[NSNumber numberWithBool:true]];
            }
            break;
            //设备离线
        case EE_DVR_CONNECT_DEVICE_ERROR:
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_OFFLINE object:self.sn];
            break;
        case EMSG_DEV_ON_DISCONNECT:
        {
            self.isConnected = false;
        }
        case EMSG_ON_DEV_DISCONNECT:
        {
            self.isConnected = false;
        }
        case EMSG_ON_MEDIA_NET_DISCONNECT:
//            [[NSNotificationCenter defaultCenter] postNotificationName:RET_DISCONNECT object:self.sn];
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
            if (msg->param1 < 0) {
                
            }else{
                if (!strcmp(msg->szStr, "ModifyPassword")) {//修改密码
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_PWD_CHANGE object:self.sn];
                }
            }
            
            break;
              
        default:
            
            break;
    }
}






//- (void)createVideoDataWithType:(enum Video_Type)type
//                   andStartTime:(int)ss
//                     andEndTime:(int)es
//                        toArray:(NSMutableArray*)array
//{
//    
//    if (_timeArray == nil) {
//        _timeArray = [NSMutableArray array];
//    }
//    
//    FileData  *data = [[FileData alloc] init];
//    data.stBeginTime = ss;
//    data.stEndTime = es;
//    
//    if (type != TYPE_NONE) {
//        [array addObject:data];
//    }
//}
//
//
//- (Video_Type)getType:(int)sdkType
//{
//    switch (sdkType) {
//        case 0:
//            return TYPE_NONE;
//        case 1:
//            return TYPE_NORMAL;
//            break;
//        case 2:
//            return TYPE_ALARM;
//            break;
//        case 3:
//            return TYPE_DETECTION;
//            break;
//        case 4:
//            return TYPE_NORMAL;
//            break;
//        case 5:
//            return TYPE_HAND;
//            break;
//        default:
//            return TYPE_NORMAL;
//            break;
//    }
//    return TYPE_NORMAL;
//}

void MD5Encrypt(signed char *strOutput, unsigned char *strInput);

+(NSString *)ToNSStr:(char *)szStr
{
    NSString *retStr = [NSString stringWithUTF8String:szStr];
    if (retStr.length == 0 && strlen(szStr) > 0) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *data = [NSData dataWithBytes:szStr length:strlen(szStr)];
        retStr = [[NSString alloc] initWithData:data encoding:enc];
    }
    return retStr;
}
@end
