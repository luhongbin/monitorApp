//
//  NetworkAssistant.h
//  FunSDKDemo
//
//  Created by riceFun on 2017/4/20.
//  Copyright © 2017年 zyj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NETWORKER [NetworkAssistant sharedInstance]

@interface NetworkAssistant : NSObject
+(NetworkAssistant *)sharedInstance;
//获取当前手机wifi的SSID(wifi名字)
-(NSString *)getCurrentPhoneWifiSSID;
//获取当前wifi的BSSID(Mac地址)
-(NSString *)getCurrentBSSID;
//获取当前IP地址
-(NSString *)getCurrentIPAddress;
//获取当前网关
-(NSString *)getCurrentGateWay;
//获取当前wifi的Mac地址
-(NSString *)getCurrentMacAddress;

-(BOOL)enableToConnectNetwork;

@end
