//
//  SDKParser.m
//  XWorld
//
//  Created by liuguifang on 16/5/31.
//  Copyright © 2016年 xiongmaitech. All rights reserved.
//

#import "SDKParser.h"
#import "FunSDK/FunSDK.h"
#import <string>
#import <strings.h>
#import "GUI.h"

#define KEY(value) #value
@implementation SDKParser

+(NSString*)parseError:(int)intError{

    NSString *intErr = [NSString stringWithFormat:@"%d", intError];
    //用plist文件取枚举值
    NSString *errorPath = [[NSBundle mainBundle] pathForResource:@"errorPList.plist" ofType:nil];
    NSDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:errorPath];
    NSString *errorString = [data valueForKey:intErr];
    if ( !errorString ) {
        return [NSString stringWithFormat:@"%@[%d]", TS("Unknown_Error"), intError];
    }
        return [NSString stringWithFormat:@"%d:%@",intError,TS(([errorString UTF8String]))];;
}

@end
