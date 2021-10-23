//
//  NSObject+SDK.h
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface SDK: NSObject
+(id) sharedSDK;
-(bool) initSDK;
-(bool) QuickConfig:(NSString *) ssid pwd:(NSString*) pwd;
-(bool) SearchDevice;
-(bool) StopQucikConfig;
-(bool) unInit;
-(void) initMC:(NSString *)token;
-(bool) Send:(NSString *) data dev:(NSString *) dev;
-(bool) Read:(NSString *)sn;
-(void) setAlarm:(bool)on sn:(NSString*) sn name:(NSString*) name;
-(void) flip:(NSString*) sn flip:(bool) flip;
-(void) timeSync:(NSString*) sn;
-(void) beep:(NSString*) sn on:(bool) on;
-(void) setOutInput:(int)level sn:(NSString *)sn;
-(void) changePwd:(NSString *) sn opwd: (NSString *)opwd npwd:(NSString *)npwd;
-(void) changePwd2:(NSString *) sn opwd: (NSString *)opwd npwd:(NSString *)npwd;
-(void) logout:(NSString*) sn;
-(void) getConfig;
-(void) getStatus:(NSString*) sn;
-(bool) searchsn:(NSString *) sn;
-(void) CheckUpgrade:(NSString*) sn;
-(void) DevStartUpgrade:(int)nType sn:(NSString *) sn;
-(void) setDST:(NSString *)mcountry sn:(NSString *)sn;
-(void) getextrecord:(NSString *)sn;
-(void) setextrecord:(NSString *)mVal sn:(NSString *)sn;

@end


