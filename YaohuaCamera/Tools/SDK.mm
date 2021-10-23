//
//  NSObject+SDK.m
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
#import "SDK.h"
#import "Global.h"
#import "getgateway.h"
#import <FunSDK/FunSDK.h>
#import "CallBackHandle.h"
#import <FunSDK/Fun_MC.h>
#import "LanguageTools.h"
#include "BasicFun.h"
#import "RET.h"
#import <UIKit/UIKit.h>
#import "ControlPlist.h"

static const char * UUID = "";
static const char * KEY = "";
static const char * SECRET = "";
static const char * UNAME = "";//"
static const char * UPASS = ""; //

static const int8  MOVEDCARD= 2; //4
NSString * mskid = @"4";
NSString * strmskValues = @"4";

@interface SDK()
@property UI_HANDLE hWnd;
@property void * pWnd;
@property NSString * sn;
@property int outLevel;
@property bool flip;
@property bool beep;
@property bool online;

@end

@implementation SDK

//+(id) sharedSDK{
//    static SDK * instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [[SDK alloc] init];
//    });
//    return instance;
//}
static SDK * instance = nil;

+(id) sharedSDK{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)logout:(NSString *)sn{
    FUN_DevLogout(self.hWnd,[sn UTF8String]);
    if ([[ControlPlist sharedInstance] isBookExistsForKey:sn]) {
        [[ControlPlist sharedInstance] removeBookWithKey:sn];
    }
    NSLog(@"删除sn%@", sn);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pWnd = (__bridge void *) self;
        self.hWnd = FUN_RegWnd(_pWnd);
    }
    return self;
}
-(void)getStatus:(NSString *)sn{
    self.sn=sn;
    [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONNECT_START object:self.sn];
    FUN_SysGetDevState(self.hWnd, [self.sn UTF8String]);
}

-(bool)searchsn:(NSString *)sn {//本地快速配置信息
    if ([[ControlPlist sharedInstance] isBookExistsForKey:sn]) { //存在，则替换之
        return true;
    }else{//不存在，则写入
        return false;
    }
}
    
-(void)flip:(NSString *)sn flip:(bool)flip{
    NSString * jsonString = @"{\"ElecLevel\":50,\"PictureMirror\":\"0x00000001\",\"RejectFlicker\":0,\"DncThr\":30,\"WhiteBalance\":\"0x0\",\"BLCMode\":\"0x0\",\"IrcutSwap\":0,\"ApertureMode\":\"0x0\",\"DayNightColor\":\"0x0\",\"PictureFlip\":\"0x00000001\",\"Day_nfLevel\":3,\"IRCUTMode\":0,\"ExposureParam\":{\"LeastTime\":\"0x100\",\"Level\":0,\"MostTime\":\"0x10000\"},\"EsShutter\":\"0x02\",\"GainParam\":{\"AutoGain\":1,\"Gain\":50},\"AeSensitivity\":5,\"Night_nfLevel\":3}";

    NSData * data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary * json = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
    
    if (flip){
        json[@"PictureFlip"] = [NSString stringWithFormat:@"0x%08x" , true];
        json[@"PictureMirror"] = [NSString stringWithFormat:@"0x%08x" , true];
    }else{
        json[@"PictureFlip"] = [NSString stringWithFormat:@"0x%08x" , false];
        json[@"PictureMirror"] = [NSString stringWithFormat:@"0x%08x" , false];
    }
    
    NSError *error;
    data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    FUN_DevSetConfig_Json(self.hWnd,[sn UTF8String], "Camera.Param", [jsonString UTF8String],(int)[jsonString length]+1, 0);
}

-(void)changePwd:(NSString *) sn opwd: (NSString *)opwd npwd:(NSString *)npwd{
    self.sn = sn;
    signed char  encryNewPsw[32] = {0};
    MD5Encrypt(encryNewPsw,(unsigned char*)[npwd UTF8String]);
    signed char  encryOldPsw[32] = {0};
    MD5Encrypt(encryOldPsw,(unsigned char*)[opwd UTF8String]);
    
    NSDictionary* dictNewUserInfo = @{ @"UserName":@"admin",
                                       @"PassWord":[NSString stringWithUTF8String: (const char*)encryOldPsw],
                                       @"NewPassWord":[NSString stringWithUTF8String: (const char*)encryNewPsw],
                                       @"EncryptType":@"MD5"
                                       };
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictNewUserInfo options:NSJSONWritingPrettyPrinted error:&error];
    NSString *strValues = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"修改密码完成，新密码：[%@],%@",strValues,sn);
    
    FUN_DevSetConfig_Json(self.hWnd, [sn UTF8String], "ModifyPassword",
                          [strValues UTF8String],(int)[strValues length]+1);
}
-(void)changePwd2:(NSString *) sn opwd: (NSString *)opwd npwd:(NSString *)npwd{
    //    self.sn = sn;
    //    self.oldPwd = opwd;
    //    self.newwPwd = npwd;
    //    FUN_DevGetConfig_Json(self.hWnd,[self.sn UTF8String], "Users",0);
//    signed char  encryNewPsw[32] = {0};
//    MD5Encrypt(encryNewPsw,(unsigned char*)[npwd UTF8String]);
//    signed char  encryOldPsw[32] = {0};
//    MD5Encrypt(encryOldPsw,(unsigned char*)[opwd UTF8String]);
//    NSString *oldpassword=[NSString stringWithUTF8String: (const char*)encryOldPsw];
//    NSString *reppassword=[NSString stringWithUTF8String: (const char*)encryNewPsw];
    //int l = FUN_SysChangeDevLoginPWD(self.hWnd,[sn UTF8String],[oldpassword UTF8String], [reppassword UTF8String] ,[reppassword UTF8String]);
    int l = FUN_SysChangeDevLoginPWD(self.hWnd,[sn UTF8String],[opwd UTF8String], [npwd UTF8String] ,[npwd UTF8String]);
    NSLog(@"修改密码完成，完成码：[%i]",l);
   // int FUN_SysChangeDevLoginPWD(UI_HANDLE hUser, const char *uuid, const char *oldpwd, const char *newpwd, const char *repwd, int nSeq = 0);// 修改设备密码(服务器端)
}

-(void) getConfig{
     FUN_DevGetConfig_Json(self.hWnd,"3b68ebc303389f17", "Users",0);
}
-(void) CheckUpgrade:(NSString*) sn{
    self.sn = sn;
    FUN_DevCheckUpgrade(self.hWnd,[sn UTF8String], 0);
}
-(void) DevStartUpgrade:(int)nType sn:(NSString*) sn{
    self.sn = sn;
    FUN_DevStartUpgrade(self.hWnd,[sn UTF8String],(int)nType,0);
}
-(void)beep:(NSString*) sn on:(bool) on{
        self.beep = on;
        self.outLevel = 0;
    self.sn = sn;
//    FUN_DevGetConfig_Json(self.hWnd ,[self.sn UTF8String], "Alarm.LocalAlarm",0,0);
    FUN_DevGetConfig_Json(self.hWnd ,[self.sn UTF8String], "Detect.MotionDetect", 0, 0);
}

-(bool)unInit{
    FUN_UnRegWnd(self.hWnd);
    FUN_UnInitNetSDK();
    FUN_UnInit();
    return true;
}
- (NSDateComponents*)getChoiseDay:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd";
    
    return [[NSCalendar currentCalendar]
            components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
            fromDate:date];
}

-(void)timeSync:(NSString*) sn{
    self.sn = sn;
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    char szTime[64] = {0};
    sprintf(szTime, "%04d-%02d-%02d %02d:%02d:%02d",
            (int)[dateComponent year], (int)[dateComponent month], (int)[dateComponent day],
            (int)[dateComponent hour], (int)[dateComponent minute], (int)[dateComponent second]);

    NSTimeZone *zone = [NSTimeZone systemTimeZone]; // 获得系统的时区
    
    int time = [zone secondsFromGMT]/60.0;
    NSString * data = [NSString stringWithFormat:@"{\"FirstUserTimeZone\" : 0, \"timeMin\" : %d }",-time];
    FUN_DevSetConfig_Json(self.hWnd, [sn UTF8String], "OPTimeSettingNoRTC", szTime, (int)strlen(szTime)+1);
    FUN_DevSetConfig_Json(self.hWnd, [sn UTF8String], "System.TimeZone", [data UTF8String], (int)strlen([data UTF8String])+1);
    FUN_DevGetConfigJson(self.hWnd, [sn UTF8String], "System.TimeZone");
//
    NSLog(@"时间区:%@",data);
    FUN_DevGetConfig_Json(self.hWnd, [sn UTF8String], "General.Location",0);
//    NSLog(@"时间区完毕:%@",data);

    //    FUN_DevOption(self.hWnd,[sn UTF8String], EDA_DEV_TANSPORT_COM_WRITE,(void *)[@"BFbU" UTF8String], 8, RS232, self.hWnd,0,"");
//    FUN_DevOption(self.hWnd,[sn UTF8String], EDOPT_DEV_TANSPORT_COM_READ,0, 8, RS232, self.hWnd,0,"");
}
-(void) setOutInput:(int)level sn:(NSString *)sn{
    self.sn = sn;
    self.outLevel = level;//报警等级
    int l = 0;//外部报警模式
    if (level < 4) {
        l = 0;
    }else if(level == 4){
        l = 2;
    }else{
        l = 2;
    }
    NSLog(@"传灯自定义报警值:%d---%i",sn,level);
    //FUN_DevGetConfig_Json(self.hWnd, [sn UTF8String], "ExtRecord.[0]",0);
    FUN_DevGetConfig_Json(self.hWnd ,[sn UTF8String], "Detect.MotionDetect", 0, 0);
    FUN_DevGetConfig_Json(self.hWnd ,[sn UTF8String], "Alarm.LocalAlarm",0,0);
    NSString * cmd = [NSString stringWithFormat:@"{ \"AlarmGrade\" : %d }",l];
    FUN_DevSetConfig_Json(self.hWnd,[sn UTF8String], "Alarm.CombineAlarm", [cmd UTF8String], (int)[cmd length] + 1);
}
-(void) getextrecord:(NSString *)sn{
    self.sn = sn;
    FUN_DevGetConfig_Json(self.hWnd, [sn UTF8String], "ExtRecord.[0]",0);
}
-(void) setextrecord:(NSString *)mVal sn:(NSString *)sn{
    self.sn = sn;
    NSLog(@"sn密码：%@",self.sn);

    NSString* string1 = @",  \"RecordMode\" : \"Close\",  \"TimeSection\" : [    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ],    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ],    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ],    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ],    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ],    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ],    [      \"1 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\",      \"0 00:00:00-24:00:00\"    ]  ],  \"Redundancy\" : false,  \"PacketLength\" : 60}";

    if ( [mVal isEqualToString: @"0"]) {
        NSString* MaskArray = @"{  \"PreRecord\" : 11,  \"Mask\" : [    [      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ]  ]";
        strmskValues = [NSString stringWithFormat:@"%@%@", MaskArray,string1];
        NSLog(@"传灯自定%s",strmskValues);
        mskid = @"0";
        FUN_DevSetConfig_Json(self.hWnd, [self.sn UTF8String], "ExtRecord",[strmskValues UTF8String], (int)[strmskValues length]+1,0,15000,1);


    } else if ( [mVal isEqualToString: @"4"] ) {
        NSString * MaskArray = @"{  \"PreRecord\" : 11,  \"Mask\" : [    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000004\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ]  ]";
        strmskValues = [NSString stringWithFormat:@"%@%@", MaskArray,string1];
        NSLog(@"传灯自定%s",strmskValues);
        mskid = @"0";
        FUN_DevSetConfig_Json(self.hWnd, [self.sn UTF8String], "ExtRecord",[strmskValues UTF8String], (int)[strmskValues length]+1,0,15000,1);

      } else  {
        NSString * MaskArray = @"{  \"PreRecord\" : 11,  \"Mask\" : [    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ],    [      \"0x00000007\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\",      \"0x00000000\"    ]  ]";
          strmskValues = [NSString stringWithFormat:@"%@%@", MaskArray,string1];
          NSLog(@"传灯自定%s",strmskValues);
          mskid = @"0";
          FUN_DevSetConfig_Json(self.hWnd, [self.sn UTF8String], "ExtRecord",[strmskValues UTF8String], (int)[strmskValues length]+1,0,15000,1);

    }
}

-(void) setDST:(NSString *)mcountry sn:(NSString *)sn{
}

-(void) setAlarm:(bool)on sn:(NSString*) sn name:(NSString*) name{
    if (on) {
        MC_LinkDev(self.hWnd, [sn UTF8String], UNAME, UPASS,0,[name UTF8String], NULL); //打开开关
        NSLog(@"注册推送:%d---%d",UNAME,UPASS);
    }else{
        MC_UnlinkDev(self.hWnd, [sn UTF8String],0); //关闭开关
    }
}

-(bool)Send:(NSString *)data dev:(NSString *)dev{
    NSLog(@"发送设置数据:%@\n",data);
    FUN_DevOption(self.hWnd,[dev UTF8String], EDA_DEV_TANSPORT_COM_WRITE,(void *)[data UTF8String], 8, RS232, self.hWnd,0,"");
    FUN_DevOption(self.hWnd,[dev UTF8String], EDOPT_DEV_TANSPORT_COM_READ,0, 8, RS232, self.hWnd,0,[self.sn UTF8String]);
    return true;
}
-(bool)Read:(NSString *)sn {
    FUN_DevOption(self.hWnd,[sn UTF8String], EDOPT_DEV_TANSPORT_COM_READ,0, 8, RS232, self.hWnd,0,"");
    return true;
}
-(bool)initSDK{
    SInitParam param;
    param.nAppType = H264_DVR_LOGIN_TYPE_MOBILE;
    FUN_Init(0, &param);
    FUN_InitNetSDK();
    
    //设置用于存储设备信息等的数据配置文件
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [pathArray lastObject];
    //设置配置文件存储目录
    FUN_SetFunStrAttr(EFUN_ATTR_CONFIG_PATH,[[path stringByAppendingString:@"/Configs/"] UTF8String]);
    //设置升级文件存储目录
    FUN_SetFunStrAttr(EFUN_ATTR_UPDATE_FILE_PATH,[[path stringByAppendingString:@"/Updates/"] UTF8String]);
    //设置临时文件存储目录
    FUN_SetFunStrAttr(EFUN_ATTR_TEMP_FILES_PATH,[[path stringByAppendingString:@"/Temps/"] UTF8String]);
    FUN_SetFunStrAttr(EFUN_ATTR_USER_PWD_DB, [[self GetDocumentPath:@"password.txt"] UTF8String]);//2018.07.06雄迈

//    //设置AP模式(app直连设备热点)下设置设备信息保存文件位置
//    FUN_SysInitAsAPModel([[path stringByAppendingString:@"/APDevs.db"] UTF8String]);
    FUN_XMCloundPlatformInit(UUID, KEY, SECRET, MOVEDCARD);
    FUN_SysInit("223.4.33.127;54.84.132.236;112.124.0.188", 15010);
//    FUN_SysInit([[path stringByAppendingString:@"/DBS.db"] UTF8String]);
    FUN_SysGetDevList(self.hWnd, UNAME,UPASS);
//    Fun_LogInit(self.hWnd, "", 0, [[path stringByAppendingString:@"/app.log"] UTF8String], 0x1);
    [self SearchDevice];
    return true;
}
-(NSString *)GetDocumentPath:(NSString *) fileName{//2018.07.06雄迈
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray lastObject];
    if (fileName != nil) {
        path = [path stringByAppendingString:@"/"];
        path = [path stringByAppendingString:fileName];
    }
    return path;
}
-(void) initMC:(NSString *)token{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *bundleIdentifiler = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    
    SMCInitInfo info = {0};
    strncpy(info.token, [token UTF8String], sizeof(info.token));
    strcpy(info.user, UNAME);
    strcpy(info.password, UPASS);
    NSLog(@"推送:%d---%d",UNAME,UPASS);
    info.language = [LanguageTools checkSystemCurrentLaguageIsChinese] ? ELG_CHINESE : ELG_ENGLISH;
    info.appType = 101;
    strncpy(info.szAppType, [bundleIdentifiler UTF8String],sizeof(info.szAppType));
    
    MC_Init(self.hWnd, &info, 0);

}

-(bool)StopQucikConfig{
    FUN_DevStopAPConfig(0x0);
    return true;
}
-(bool)SearchDevice{
    FUN_DevSearchDevice(self.hWnd,5000,0);
    return true;
}
-(bool)QuickConfig:(NSString *)ssid pwd:(NSString *)pwd{
    if (ssid == nil || pwd == nil) {
        return false;
    }
    NSString * macStr = [Global getCurrentMac];
    in_addr_t addr = 0;// 准备配置信息
    getdefaultgateway(&addr);
    char szGetWay[64] = {0};
    IP2Str(addr, szGetWay);
    NSString *testip = [Global getCurrentIPAddress];
    char data[512] = {0};
    char infof[512] = {0};
    //char IP[64] = {0};
    char szPwd[64] = {0};
    strncpy(szPwd, [pwd UTF8String], 63);
    int encmode = 0;
    
    sprintf(data, "S:%sP:%sT:%d", [ssid UTF8String], szPwd, encmode);
    sprintf(infof, "gateway:%s ip:%s submask:%s dns1:%s dns2:%s mac:0", szGetWay, [testip UTF8String],"255.255.255.0",szGetWay,szGetWay);
    
    unsigned int mac[6];
    unsigned char mac2[6];
    
    if ([macStr length] == 0) {
        macStr = @"0:0:0:0:0:0";
    }
    sscanf([macStr UTF8String], "%x:%x:%x:%x:%x:%x", &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
    for (int i = 0; i < 6; ++i) {
        mac2[i] = mac[i];
    }
    FUN_DevStopAPConfig();
    FUN_DevStartAPConfig(self.hWnd, 3, [ssid UTF8String],data, infof, szGetWay, encmode, 1, mac2,120000);
    
    //写夏令时
    return true;
}

-(void)OnFunSDKResult:(NSNumber *)param{
    NSInteger data = [param integerValue];
    MsgContent *msg = (MsgContent *)data;
    NSLog(@"============[ret] %d======param1 %d==============%s",msg->id,msg->param1,msg->pObject);
    
    switch (msg->id) {
        case  EMSG_SYS_GET_DEV_INFO_BY_USER:
        {
            NSLog(@"EMSG_SYS_GET_DEV_INFO_BY_USER %d,p1:%d",msg->id,msg->param1);
        }
        case     EMSG_SYS_GET_DEV_INFO_BY_USER_XM:
        {
            NSLog(@"EMSG_SYS_GET_DEV_INFO_BY_USER_XM %d,p1:%d",msg->id,msg->param1);
        }
        case EMSG_SYS_GET_DEV_STATE:
        {
            NSLog(@"EMSG_SYS_GET_DEV_STATE %d,p1:%d,p2:%d,p3:%d",msg->id,msg->param1,msg->param2,msg->param3);
            
            self.online = msg->param1 > 0;
            if (!self.online) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_OFFLINE object:self.sn];
            }else{
                //[self connect];
            }
        }
        case EMSG_DEV_CHECK_UPGRADE:  //设备升级
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_UPGRADE object:[NSNumber numberWithInt:msg->param1]];
            break;
        }
        case EMSG_DEV_AP_CONFIG: //快速配置
            if (msg->param1 > 0) {
                SDK_CONFIG_NET_COMMON_V2  device = *(SDK_CONFIG_NET_COMMON_V2*)(msg->pObject);
                NSLog(@"快速配置成功%s",device.sSn);
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_QUICKCONFIG_SUCCESS object:[SDK ToNSStr:device.sSn]];
                //获得系统时间
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式,这里可以设置成自己需要的格式
                NSString *addDate1 = [dateFormatter stringFromDate:[NSDate date]];//用[NSDate date]可以获取系统当前时间
                NSLog(@"%@",addDate1);//输出格式为：2010-10-27 10:22:13
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); //char转NSString重点
                NSString *sn = [[NSString alloc] initWithCString:device.sSn  encoding:enc];
                //准备将该sn写入plist文件供修改密码权限判断
                ControlPlist *sss = [[ControlPlist alloc] init ];
                NSString *plistPath =[[ControlPlist sharedInstance] getPlistPath];
                if( [sss isPlistFileExists]== NO ) {//不存在
                    NSLog(@"Books.plist not exists ,build it.");
                    NSMutableDictionary *addDictionary1 = [[NSMutableDictionary alloc] init];
                    [addDictionary1 setValue:addDate1 forKey:@"date"];
                    
                    [[ControlPlist sharedInstance]writePlist:addDictionary1 forKey:sn];
                }else{
                 NSLog(@"已经存在%s",device.sSn);
                }
                NSMutableDictionary *addDictionary1 = [[NSMutableDictionary alloc] init];
                [addDictionary1 setValue:addDate1 forKey:@"date"];
                //判断给出的Key对应的数据是否存在
                if ([[ControlPlist sharedInstance] isBookExistsForKey:sn]) {
                    NSLog(@"存在，则替换之");
                    [[ControlPlist sharedInstance] replaceDictionary:addDictionary1 withDictionaryKey:sn];
                }else{//不存在，则写入
                    NSLog(@"不存在，则写入");
                    [[ControlPlist sharedInstance] writePlist:addDictionary1 forKey:sn];
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_QUICKCONFIG_SUCCESS object:nil];
                NSLog(@"快速配置失败");
            }
            break;
        case EMSG_DEV_SEARCH_DEVICES://设备搜索
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
        case EMSG_MC_LinkDev://注册推送
        {
            NSLog(@"EMSG_MC_LinkDev:%d",msg->param1);
            if (msg->param1 < 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_LINK object:[NSNumber numberWithBool:false]];
                NSLog(@"注册推送失败");
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_LINK object:[NSNumber numberWithBool:true]];
                NSLog(@"注册推送成功");
            }
        }
            break;
        case EMSG_MC_UnlinkDev: //解除推送
        {
            NSLog(@"解除推送EMSG_MC_UnlinkDev:%d",msg->param1);
            if (msg->param1 < 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_UN_LINK object:[NSNumber numberWithBool:false]];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_MC_UN_LINK object:[NSNumber numberWithBool:true]];
            }
        }
            break;
        case EMSG_DEV_SET_CONFIG_JSON:
        {
            if (msg->param1 < 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_GDPR object:[NSNumber numberWithBool:false]];
                NSLog(@"更改失败");
                return;
            }else{
                NSLog(@"EMSG_DEV_SET_CONFIG_JSON:%@",mskid);
                if (mskid == @"0") {
                    FUN_DevSetConfig_Json(self.hWnd, [self.sn UTF8String], "Record",[strmskValues UTF8String], (int)[strmskValues length]+1,0,15000,1);
                    mskid = @"1";
                    NSLog(@"注册extrecord成功");
                }
                if (mskid == @"1")  {
                    // if ([rsstrValues containsString:@"\"Record.[0]"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_GDPR object:[NSNumber numberWithBool:true]];
                    NSLog(@"注册record成功");
                    // }
                }
                
            }
            if   (msg->param1 < 0 ) return;
            if (!strcmp(msg->szStr, "ModifyPassword")) {//修改密码
                 [[NSNotificationCenter defaultCenter] postNotificationName:RET_PWD_CHANGE object:self.sn];
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
        case EMSG_DEV_ON_TRANSPORT_COM_DATA://串口收到数据
        {
            NSLog(@"收到串口数据:[%s] from [%s]",msg->pObject,msg->szStr);
            [[NSNotificationCenter defaultCenter] postNotificationName:RET_CONFIG object:[NSString stringWithUTF8String:msg->pObject]];
        }
            
            break;
        case EMSG_DEV_GET_CONFIG_JSON:
        {
            NSLog(@"这个是官方返回的EMSG_DEV_GET_CONFIG_JSON 第一部分:%d",msg->param1);
            NSLog(@"这个是官方返回的EMSG_DEV_GET_CONFIG_JSON 第二部分:%d",msg->szStr);
            NSLog(@"这个是官方返回的EMSG_DEV_GET_CONFIG_JSON 第三部分:%d",msg->pObject);

            if (!strcmp(msg->szStr, "ExtRecord.[0]")) {
                printf("ExtRecordreturn.[0]-%s",msg->pObject);

                NSData * data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if   (msg->param1 < 0 ) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"f" forKey:@"ExtRecordMask"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RET_GD object:[NSString stringWithUTF8String:"false"]];
                    return;
                }
                if ( data == nil )
                    return;
                //[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ExtRecordMasksource"];
                NSString * MaskArr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
               // [[NSNotificationCenter defaultCenter] postNotificationName:CHECK_GDPR object:[NSNumber numberWithInt:msg->param1]];
                NSString * detailStr = [MaskArr stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];//去空格
                NSString *MaskArray3 =  [detailStr substringToIndex:46];
                NSString *last = [MaskArray3 substringFromIndex:MaskArray3.length-1];//字符串结尾
                NSLog(@"这个是data:%@",last);
                [[NSUserDefaults standardUserDefaults] setObject:last forKey:@"ExtRecordMask"];
                [[NSNotificationCenter defaultCenter] postNotificationName:RET_GD object:last];
                //NSLog(@"这个是ExtRecordMask:%s",last);
            }
            if (!strcmp(msg->szStr, "System.TimeZone")) {
                printf("System.TimeZone: %s",msg->pObject);
            }
            if(!strcmp(msg->szStr, "General.Location")){
                NSLog(@"启动时区成功");
                NSData * data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil )
                    return;
               NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
                NSLog(@"原时间夏令时设置2:%@",dic);

                NSMutableDictionary * md0 = [NSMutableDictionary dictionaryWithDictionary:[dic valueForKey:@"General.Location.[0]"]];
                NSMutableDictionary * dictDSTEnd = [NSMutableDictionary dictionaryWithDictionary:[md0 valueForKey:@"DSTEnd"]];
                NSMutableDictionary * dictDSTStart = [NSMutableDictionary dictionaryWithDictionary:[md0 valueForKey:@"DSTStart"]];
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
                NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
                
                comps = [calendar components:unitFlags fromDate:[NSDate date]];
                NSInteger myear=[comps year];
                int MonthStart = 3;
                int WeekStart = 5;
                int DayStart = 0;
                int HourStart = 1;
                int MonthEnd = 10;
                int WeekEnd = -1;
                int DayEnd = 0;
                int HourEnd = 2;
                int mno = 1;

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *mcountry = [defaults objectForKey : @"ISOcountryCode" ];
                if ([mcountry isEqualToString:@"GB"] || [mcountry isEqualToString:@"IE"] || [mcountry isEqualToString:@"PT"] ) {
                    MonthStart = 3;
                    WeekStart = 5;
                    DayStart = 0;
                    HourStart = 1;
                    MonthEnd = 10;
                    WeekEnd = -1;
                    DayEnd = 0;
                    HourEnd = 2;
                } else if ([mcountry isEqualToString:@"ES"] || [mcountry isEqualToString:@"DE"] || [mcountry isEqualToString:@"FR"] || [mcountry isEqualToString:@"NL"] || [mcountry isEqualToString:@"BE"] || [mcountry isEqualToString:@"IT"] || [mcountry isEqualToString:@"PL"] || [mcountry isEqualToString:@"AT"] || [mcountry isEqualToString:@"CH"] || [mcountry isEqualToString:@"IE"] || [mcountry isEqualToString:@"SE"] || [mcountry isEqualToString:@"DK"] || [mcountry isEqualToString:@"SK"] || [mcountry isEqualToString:@"SE"] || [mcountry isEqualToString:@"SI"] || [mcountry isEqualToString:@"HR"] || [mcountry isEqualToString:@"HU"] || [mcountry isEqualToString:@"DK"] ) {
                    MonthStart = 3;
                    WeekStart = 5;
                    DayStart = 0;
                    HourStart = 2;
                    MonthEnd = 10;
                    WeekEnd = -1;
                    DayEnd = 0;
                    HourEnd = 3;
                } else if ([mcountry isEqualToString:@"FI"] || [mcountry isEqualToString:@"RO"] || [mcountry isEqualToString:@"LT"] || [mcountry isEqualToString:@"BG"] || [mcountry isEqualToString:@"EE"] || [mcountry isEqualToString:@"CZ"] ) {
                    MonthStart = 3;
                    WeekStart = 5;
                    DayStart = 0;
                    HourStart = 3;
                    MonthEnd = 10;
                    WeekEnd = -1;
                    DayEnd = 0;
                    HourEnd = 4;
                } else if ([mcountry isEqualToString:@"AU"]) {
                    MonthStart = 10;
                    WeekStart = -1;
                    DayStart = 0;
                    HourStart = 2;
                    MonthEnd = 4;
                    WeekEnd = 1;
                    DayEnd = 0;
                    HourEnd = 3;
                } else if ([mcountry isEqualToString:@"NZ"]) {
                    MonthStart = 9;
                    WeekStart = 5;
                    DayStart = 0;
                    HourStart = 2;
                    MonthEnd = 4;
                    WeekEnd = 1;
                    DayEnd = 0;
                    HourEnd = 3;
                } else if ([mcountry isEqualToString:@"CA"] || [mcountry isEqualToString:@"US"]) {
                    MonthStart = 3;
                    WeekStart = 2;
                    DayStart = 0;
                    HourStart = 2;
                    MonthEnd = 11;
                    WeekEnd = 1;
                    DayEnd = 0;
                    HourEnd = 2;
                } else if ([mcountry isEqualToString:@"MX"]) {
                    MonthStart = 4;
                    WeekStart = -1;
                    DayStart = 0;
                    HourStart = 2;
                    MonthEnd = 10;
                    WeekEnd = -1;
                    DayEnd = 0;
                    HourEnd = 2;
                }else if ([mcountry isEqualToString:@"LU"] || [mcountry isEqualToString:@"GR"]) {
                    MonthStart = 3;
                    WeekStart = 5;
                    DayStart = 0;
                    HourStart = 2;
                    MonthEnd = 10;
                    WeekEnd = -1;
                    DayEnd = 0;
                    HourEnd = 3;
                } else {
                    mno = 0;
                }
                NSLog(@"mno设置:%d,%@",mno,mcountry);
                if (mno == 0) {
                    return;
                }
                dictDSTEnd[@"Day"] = [NSNumber numberWithInt:DayEnd];
                dictDSTEnd[@"Hour"] = [NSNumber numberWithInt:HourEnd];
                dictDSTEnd[@"Minute"] = [NSNumber numberWithInt:0];
                dictDSTEnd[@"Month"] = [NSNumber numberWithInt:MonthEnd];
                dictDSTEnd[@"Week"] = [NSNumber numberWithInt:WeekEnd];
                dictDSTEnd[@"Year"] = [NSNumber numberWithInt:myear];
                dictDSTStart[@"Day"] = [NSNumber numberWithInt:DayStart];
                dictDSTStart[@"Hour"] = [NSNumber numberWithInt:HourStart];
                dictDSTStart[@"Minute"] = [NSNumber numberWithInt:0];
                dictDSTStart[@"Month"] = [NSNumber numberWithInt:MonthStart];
                dictDSTStart[@"Week"] = [NSNumber numberWithInt:WeekStart];
                dictDSTStart[@"Year"] = [NSNumber numberWithInt:myear];
//                md0[@"DateFormat"] = [md0 valueForKey:@"DateFormat"];
//                md0[@"DateSeparator"] =[md0 valueForKey:@"DateSeparator"];
//                md0[@"Language"] = [md0 valueForKey:@"Language"];
//                md0[@"TimeFormat"] =[md0 valueForKey:@"TimeFormat"];
//                md0[@"VideoFormat"] = [md0 valueForKey:@"VideoFormat"];
//                md0[@"WorkDay"] =[md0 valueForKey:@"WorkDay"];
                md0[@"DSTRule"] =  [NSString stringWithFormat:@"On"];
                md0[@"DSTEnd"] = dictDSTEnd;
                md0[@"DSTStart"] = dictDSTStart;
                dic[@"General.Location"] = md0;
                NSError *error;
                NSData *data1 = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                NSMutableDictionary * dicx = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingAllowFragments error:nil]];
                NSLog(@"时间夏令时设置:%@,%@",dicx,mcountry);
                NSString *strValues = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                //NSString* strValues = @"{\"General.Location\" : { \"DSTEnd\" : { \"Day\" : 1, \"Hour\" : 1, \"Minute\" : 1, \"Month\" : 12, \"Week\" : 1, \"Year\" : 2017 }, \"DSTRule\" : \"On\", \"DSTStart\" : { \"Day\" : 1, \"Hour\" : 1, \"Minute\" : 1, \"Month\" : 5, \"Week\" : 0, \"Year\" : 2018 }, \"DateFormat\" : \"YYMMDD\", \"DateSeparator\" : \"-\", \"Language\" : \"SimpChinese\", \"TimeFormat\" : \"24\", \"VideoFormat\" : \"PAL\", \"WorkDay\" : 62 }, \"Name\" : \"General.Location\", \"Ret\" : 100, \"SessionID\" : \"0x00000030\" }";
                //FUN_DevSetConfig_Json(self.hWnd, "a9134fa694a8ab75", "General.Location", [strValues UTF8String], (int)[strValues length]+1, 0, 15000, 1);
                FUN_DevSetConfig_Json(self.hWnd, [self.sn UTF8String], "General.Location",[strValues UTF8String], (int)[strValues length]+1,0,15000,1);
            }

           if(!strcmp(msg->szStr, "Detect.MotionDetect")){
                NSData * data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil )
                    return;
                NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
                NSMutableDictionary * md0 = [NSMutableDictionary dictionaryWithDictionary:[dic valueForKey:@"Detect.MotionDetect.[0]"]];
                NSMutableDictionary * dictHandler = [NSMutableDictionary dictionaryWithDictionary:[md0 valueForKey:@"EventHandler"]];
                dictHandler[@"RecordEnable"] = [NSNumber numberWithBool:true];
                dictHandler[@"AlarmOutEnable"] = [NSNumber numberWithBool:true];
                dictHandler[@"MessageEnable"] = [NSNumber numberWithBool:true];
                dictHandler[@"MsgtoNetEnable"] = [NSNumber numberWithBool:true];
                if (self.outLevel != 0) {
                    switch (self.outLevel) {
                        case 1://外部报警级别且,移动侦测低
                            {
                                NSMutableArray* arrayRegion = [NSMutableArray arrayWithCapacity:32];
                                for(int i= 0; i < 32; i++)
                                {
                                    char szMask[16] = {0};
                                    sprintf(szMask, "0x%08x", 0xFFFFFFFF);
                                    arrayRegion[i] = [NSString stringWithUTF8String:szMask];
                                }
                                md0[@"Region"] = arrayRegion;
                                md0[@"Enable"] = [NSNumber numberWithBool:true];
                                md0[@"Level"] = [NSNumber numberWithInt:1];
                            }
                            break;
                        case 2://外部报警级别且,移动侦测中
                            md0[@"Enable"] = [NSNumber numberWithBool:true];
                            md0[@"Level"] = [NSNumber numberWithInt:3];
                            break;
                        case 3://外部报警级别且,移动侦测高
                            md0[@"Enable"] = [NSNumber numberWithBool:true];
                            md0[@"Level"] = [NSNumber numberWithInt:6];
                            break;
                        case 4://外部报警级别或,移动侦测无
                            {
                                md0[@"Enable"] = [NSNumber numberWithBool:true];
                                md0[@"Level"] =[NSNumber numberWithInt:1];
                                NSMutableArray* arrayRegion = [NSMutableArray arrayWithCapacity:32];
                                
                                for(int i= 0; i < 32; i++)
                                {
                                    char szMask[16] = {0};
                                    sprintf(szMask, "0x%08x", 0x00000000);
                                    arrayRegion[i] = [NSString stringWithUTF8String:szMask];
                                }
                                md0[@"Region"] = arrayRegion;
                            }
                            break;
                        case 5://外部报警级别或,移动侦测低
                            md0[@"Enable"] = [NSNumber numberWithBool:true];
                            md0[@"Level"] =[NSNumber numberWithInt:1];
                            break;
                        case 6://外部报警级别2,移动侦测中
                            md0[@"Enable"] = [NSNumber numberWithBool:true];
                            md0[@"Level"] =[NSNumber numberWithInt:3];
                            break;
                        case 7://外部报警级别2,移动侦测高
                            {
                                NSMutableArray* arrayRegion = [NSMutableArray arrayWithCapacity:32];
                                for(int i= 0; i < 32; i++)
                                {
                                    char szMask[16] = {0};
                                    sprintf(szMask, "0x%08x", 0xFFFFFFFF);
                                    arrayRegion[i] = [NSString stringWithUTF8String:szMask];
                                }
                                md0[@"Region"] = arrayRegion;
                                md0[@"Enable"] = [NSNumber numberWithBool:true];
                                md0[@"Level"] =[NSNumber numberWithInt:1];
                            }
                            break;
                        default:
                            md0[@"Enable"] = [md0 valueForKey:@"Enable"];
                            md0[@"Level"] =[md0 valueForKey:@"Level"];
                            break;
                    }
                }else{
                    dictHandler[@"BeepEnable"] = [NSNumber numberWithBool:self.beep];
                }
                md0[@"EventHandler"] = dictHandler;
                
                NSError *error;
                NSData *data1 = [NSJSONSerialization dataWithJSONObject:md0 options:NSJSONWritingPrettyPrinted error:&error];
                NSString *strValues = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                FUN_DevSetConfig_Json(self.hWnd,[self.sn UTF8String], "Detect.MotionDetect",[strValues UTF8String], (int)[strValues length]+1,0);
                
                self.outLevel = 0;
            }else if(!strcmp(msg->szStr, "Alarm.LocalAlarm")){
                NSData * data = [[[NSString alloc]initWithUTF8String:msg->pObject] dataUsingEncoding:NSUTF8StringEncoding];
                if ( data == nil )
                    return;
                NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]];
                
                NSMutableDictionary * md0 = [NSMutableDictionary dictionaryWithDictionary:[dic valueForKey:@"Alarm.LocalAlarm.[0]"]];
                md0[@"Enable"] = [NSNumber numberWithBool:true];
                
                NSError *error;
                NSData *data1 = [NSJSONSerialization dataWithJSONObject:md0 options:NSJSONWritingPrettyPrinted error:&error];
                NSString *strValues = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
                FUN_DevSetConfig_Json(self.hWnd, [self.sn UTF8String], "Alarm.LocalAlarm",[strValues UTF8String], (int)[strValues length]+1,0);
            }
            printf("这才算完事");
        }
            break;
        default:
            break;
    }
}

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
