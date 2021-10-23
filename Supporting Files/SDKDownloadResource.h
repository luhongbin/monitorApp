//
//  SDKDownloadResource.h
//  FunSDKDemo
//
//  Created by riceFun on 2017/4/22.
//  Copyright © 2017年 zyj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDKDownloadResource : NSObject<NSCoding>

typedef NS_ENUM(NSInteger, ResourceType) {
    ResourceTypePic,
    ResourceTypeVideo,
    ResourceTypePicFisheye,
    ResourceTypeVideoFisheye
};

typedef NS_ENUM(NSInteger, DownloadState) {
    DownloadStateNot,
    DownLoadWait,
    DownloadStateDownloading,
    DownloadStateCompleted,
};

@property (nonatomic, copy) NSString *name;//资源名称
@property (nonatomic, copy) NSString *dateString;//资源日期
@property (nonatomic, copy) NSString* beginTime;//开始时间
@property (nonatomic, copy) NSString* endTime;//结束时间
@property (nonatomic, assign) float progress;//资源下载进度
@property (nonatomic,copy) NSString* devId;//设备ID
@property (nonatomic, assign) int channelNum;//通道号
@property (nonatomic,assign) int size;//文件大小
@property (nonatomic,copy) NSString* storePath;//存储路径
@property (nonatomic, assign) DownloadState downloadState;//正在下载
@property (nonatomic,assign) ResourceType type;//资源类型
@property (nonatomic, assign) int index;//序号 在文件回调数组中的排列序号


@end
