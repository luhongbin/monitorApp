//
//  Recode.m
//  界面1
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

#import "Recode.h"
#import <AVFoundation/AVAudioSession.h>
#import "RET.h"

@implementation Recode
@synthesize aqc;

static void AQInputCallback(void         *inUserData,
                            AudioQueueRef    inAudioQueue,
                            AudioQueueBufferRef  inBuffer,
                            const AudioTimeStamp *inStartTime,
                            UInt32      inNumPackets,
                            const AudioStreamPacketDescription * inPacketDesc)
{
    Recode *engine = (__bridge Recode *)inUserData;
    
    if (inNumPackets >0) {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    
    if (engine.aqc.run) {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (id)init:(const char *) sn{
    self = [super init];
    
    if (self)
    {
        self.devSn = sn;
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        //设置录音采样率
        aqc.mDataFormate.mSampleRate = kSamplingRate;
        //设置录音格式
        aqc.mDataFormate.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormate.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormate.mFramesPerPacket = 1;
        aqc.mDataFormate.mChannelsPerFrame = kNumberChannels;
        
        aqc.mDataFormate.mBitsPerChannel = kBitesPerChannels;
        
        aqc.mDataFormate.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormate.mBytesPerFrame = kBytesPerFrame;
        
        aqc.frameSize = kFrameSize;
    }
    return self;
}
- (void)stop
{
    AudioQueueStop(aqc.queue, true);
    AudioQueueDispose(aqc.queue, true);
}
-(void)start{
    AudioQueueNewInput(&aqc.mDataFormate, AQInputCallback, (__bridge void *)(self), NULL, NULL,0, &aqc.queue);
    
    for (int i=0;i<kNumberBuffers;i++)
    {
        AudioQueueAllocateBuffer(aqc.queue, (int) aqc.frameSize, &aqc.mBuffers[i]);
        AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
    }
    
    aqc.recPtr = 0;
    aqc.run = 1;
    
    UInt32 enabledLevelMeter = true;
    AudioQueueSetProperty(aqc.queue, kAudioQueueProperty_EnableLevelMetering, &enabledLevelMeter, sizeof(UInt32));
    
    AudioQueueStart(aqc.queue, NULL);
}



- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    
    long size = buffer->mAudioDataByteSize / aqc.mDataFormate.mBytesPerPacket;
    char * srcData = (char *) buffer->mAudioData;
    int dataSize = buffer->mAudioDataByteSize;
    FUN_DevSendTalkData(self.devSn,srcData,dataSize);
    
    NSLog(@"数据大小%d",dataSize);
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(aqc.queue, kAudioQueueProperty_CurrentLevelMeterDB, &levelMeter, &levelMeterSize);
    double volume = -levelMeter.mAveragePower;
    NSLog(@"音量大小:%f分贝",volume);
    [[NSNotificationCenter defaultCenter] postNotificationName:RET_DB object: [NSNumber numberWithDouble:volume]];
    
   
}

@end
