//
//  CallBackHandle.h
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
//
#define UI_HANDLE int
#ifndef CallBackHandle_h
#define CallBackHandle_h
#import <Foundation/Foundation.h>
#import "FileData.h"



@interface CallBackHandle: NSObject
@property UI_HANDLE hWnd;
@property void * pWnd;
@property  NSString * date;
@property bool isConnected;
#pragma mark 回调函数
-(void)OnFunSDKResult:(NSNumber*)param;
@property NSString * sn;
@property bool beep;
@property NSDateComponents * dateEnd;
@property NSString * oldPwd;
@property NSString * ewPwd;
@property bool flip;
@property int outLevel;
@end
#endif /* CallBackHandle_h */
