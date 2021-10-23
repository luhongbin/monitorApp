//
//  Global.m
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Global
+ (long long) getInterfaceBytes
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return 0;
    }
    
    uint32_t iBytes = 0;
    uint32_t oBytes = 0;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        /* Not a loopback device. */
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
        }
    }
    freeifaddrs(ifa_list);
    
    NSLog(@"\n[getInterfaceBytes-Total]%d,%d",iBytes,oBytes);
    return (iBytes + oBytes) / 1024 / 1024;
}
+(NSString *)subString:(NSString *)content startIndex:(int)startIndex length:(int)length {
    NSString* result = [content substringWithRange:NSMakeRange(startIndex, length)];
    return result;
}

+(NSString *)getCurrentSSID;
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id infoDic = nil;
    for (NSString *ifnam in ifs) {
        infoDic = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, infoDic);
        //if (infoDic && [infoDic count]) { break; }
    }
    const char *charSSID = [[infoDic objectForKey:@"SSID"] UTF8String];
    NSLog(@"%s",charSSID);
//    if (TARGET_IPHONE_SIMULATOR) {
//        charSSID = "GunMa";
//    }
    if (charSSID == NULL) {
        return @"";
    }
    NSString *ssid = [NSString stringWithUTF8String:charSSID];
    return ssid;
}

+(NSString *)getCurrentMac
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id infoDic = nil;
    for (NSString *ifnam in ifs) {
        infoDic = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, infoDic);
        //if (infoDic && [infoDic count]) { break; }
    }
    const char *charMac = [[infoDic objectForKey:@"BSSID"] UTF8String];
    NSLog(@"%s",charMac);
//    if (TARGET_IPHONE_SIMULATOR) {
//        charMac = "kuozhanbu";
//    }
    if (charMac == NULL) {
        return @"";
    }
    NSString *Mac = [NSString stringWithUTF8String:charMac];
    return Mac;
}

+(NSString *)getCurrentIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}

@end
