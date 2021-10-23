//
//  SDKDownloadResource.m
//  FunSDKDemo
//
//  Created by riceFun on 2017/4/22.
//  Copyright © 2017年 zyj. All rights reserved.
//

#import "SDKDownloadResource.h"

@implementation SDKDownloadResource

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _name = @"";
        _dateString = @"";
        _beginTime = @"";
        _endTime = @"";
        _progress = 0.0f;
        _devId = @"";
        _channelNum = 0;
        _size = 0;
        _type = 0;
        _downloadState = DownloadStateNot;
        _index = 0;
    }
    
    return self;
}

//将对象编码(即:序列化)
-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_dateString forKey:@"dateString"];
    [aCoder encodeObject:_beginTime forKey:@"beginTime"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
    [aCoder encodeFloat:_progress forKey:@"progress"];
    
    [aCoder encodeObject:_devId forKey:@"devId"];
    [aCoder encodeInteger:_channelNum forKey:@"channelNum"];
    [aCoder encodeInteger:_size forKey:@"size"];
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeInteger:_index forKey:@"index"];

}

//将对象解码(反序列化)
-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _dateString = [aDecoder decodeObjectForKey:@"dateString"];
        _beginTime = [aDecoder decodeObjectForKey:@"beginTime"];
        _endTime = [aDecoder decodeObjectForKey:@"endTime"];
        _progress = [aDecoder decodeFloatForKey:@"progress"];
        
        _devId = [aDecoder decodeObjectForKey:@"devId"];
        _channelNum = [aDecoder decodeIntForKey:@"channelNum"];
        _size = [aDecoder decodeIntForKey:@"size"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
        _index = [aDecoder decodeIntForKey:@"index"];
    }
    return (self);
    
}

@end

