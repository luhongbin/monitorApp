//
//  Recode.h
//  界面1
//
//  Created by hzjf on 14-1-7.
//  Copyright (c) 2014年 hzjf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "FunSDK/FunSDK.h"

#define kNumberBuffers 3
#define t_sample     SInt16
#define kSamplingRate   8000
#define kNumberChannels  1
#define kBitesPerChannels  (sizeof(t_sample) * 8)
#define kBytesPerFrame   (kNumberChannels * sizeof(t_sample))
#define kFrameSize      640


typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormate;
    AudioQueueRef        queue;
    AudioQueueBufferRef     mBuffers[kNumberBuffers];
    AudioFileID          outputFile;
    unsigned long        frameSize;
    long long           recPtr;
    int               run;
    
} AQCallbackStruct;

@interface Recode : NSObject
{
    AQCallbackStruct aqc;
}
- (id)init:(const char *) devSn;
-(void) start;
- (void)stop;
- (void)processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef)queue;
@property (nonatomic, assign)AQCallbackStruct aqc;
@property const char * devSn;
@end
