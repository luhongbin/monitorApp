//
//  DisplayView.h
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//
#define UI_HANDLE int
#import <UIKit/UIKit.h>
#import "FileData.h"

typedef enum Video_Type // 录像类型
{ TYPE_NONE,
    TYPE_NORMAL,    // 普通录像
    TYPE_ALARM,     // 报警录像
    TYPE_DETECTION, // 检测录像
    TYPE_HAND,      // 手动录像
    TYPE_CONTROL    // 遥控录像
} Video_Type;

struct VIDEO_CONTENT // 视频参数
{
    Video_Type type;
    int start_Time;
    int end_Time;
};

typedef struct ByteRecordType
{
    unsigned char t0:4;
    unsigned char t1:4;
}ByteRecordType;

static NSString * RET_RECORD = @"RET_RECORD";

//  视频播放视图
@interface DisplayView : UIView
@property bool  isConnected;
@property NSMutableArray<FileData *> * timeArray;
@property NSMutableArray<NSNumber *> * dateArray;
@property NSString * newwPwd;
-(void) load:(NSString *) sn pwd:(NSString*) pwd;
-(void) connect;
-(void) play:(int) streamType;
-(void) stop;
-(void) pause :(int) pauseOrResume;
-(bool) isPlaying;
-(void) shot;
-(void) getStatus;
-(void) sound:(bool) on;
-(void) record:(bool) on;
-(void) talk:(bool) on;
-(void) disconnect;
-(void) replay:(NSDateComponents *)startTime end:(NSDateComponents *)endTime;
-(void) monthData;
-(void) seek:(int) time;
-(void) autoType;
-(void) search:(NSDateComponents *)startTime end:(NSDateComponents *)endTime;
@end
