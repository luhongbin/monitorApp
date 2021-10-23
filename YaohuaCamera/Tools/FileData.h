//
//  FileDate.h
//  YaohuaCamera
//
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
#ifndef _FILEDATE
#define _FILEDATE

#import <Foundation/Foundation.h>

/// 系统时间结构
typedef struct SDK_TIME {
    int  year;///< 年。
    int  month;///< 月，January = 1, February = 2, and so on.
    int  day;///< 日。
    int  wday;///< 星期，Sunday = 0, Monday = 1, and so on
    int  hour;///< 时。
    int  minute;///< 分。
    int  second;///< 秒。
    int  isdst;///< 夏令时标识。
}SDK_TIME;

@interface FileData : NSObject
@property (nonatomic) int stBeginTime;//文件开始时间
@property (nonatomic) int stEndTime;	//文件结束时间
@end


#endif /* FileDate_h */
