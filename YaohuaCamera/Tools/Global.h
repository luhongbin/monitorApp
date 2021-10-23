//
//  Global.h
//  SDKDemo
//
//  Created by zyj on 15/7/20.
//  Copyright (c) 2015年 wcq. All rights reserved.
//
@interface Global : NSObject
+(NSString *) getCurrentSSID;
+(NSString *) getCurrentMac;
+(NSString *) getCurrentIPAddress;
+(long long) getInterfaceBytes;
@end

