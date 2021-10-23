//
//  NetworkAssistant.m
//  FunSDKDemo
//
//  Created by riceFun on 2017/4/20.
//  Copyright © 2017年 zyj. All rights reserved.
//

#import "NetworkAssistant.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "XMNetInterface/Reachability.h"
#import "XMNetInterface/NetInterface.h"

@interface NetworkAssistant()
@property (nonatomic,strong)NSDictionary *netInfoDic;
@end

@implementation NetworkAssistant
+(NetworkAssistant *)sharedInstance{
    static NetworkAssistant *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(NSDictionary *)getNetInfoDic{
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    
    NSDictionary *info = nil;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            
            break;
            
        }
        
    }
    
    return info;

}

//获取当前手机wifi的SSID(wifi名字)
-(NSString *)getCurrentPhoneWifiSSID{
    NSString *ssid = [self getNetInfoDic][@"SSID"];//WiFi名称
    return ssid;
}


//获取当前wifi的BSSID(Mac地址)
-(NSString *)getCurrentBSSID{
    NSString *bssid = [self getNetInfoDic][@"BSSID"];//无线网的MAC地址
    return bssid;
}

//获取当前IP地址
-(NSString *)getCurrentIPAddress{
    NSString *ip = [NetInterface getCurrent_IP_Address];
    return ip;
}
//获取当前网关
-(NSString *)getCurrentGateWay{
    NSString* sGateway = [NetInterface getDefaultGateway];
    return sGateway;
}

//获取当前wifi的Mac地址
-(NSString *)getCurrentMacAddress{
    NSString *mac = [NetInterface getCurrent_Mac];
    return mac;
}

-(BOOL)enableToConnectNetwork{
    return [NetInterface enableToConnectNetwork];
}
@end
