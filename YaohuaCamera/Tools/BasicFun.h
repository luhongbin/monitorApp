//
//  SDKBasicFun.h
//  SDKDemo
//
//  Created by wcq on 14/11/12.
//  Copyright (c) 2014年 wcq. All rights reserved.
//

#include <time.h>
#include "FunSDK/netsdk.h"

class BasicFun {
public:
    BasicFun(){};
    ~BasicFun(){};
    static time_t ToTime_t(SDK_SYSTEM_TIME *pDvrTime);
    static time_t ToTime_t(H264_DVR_TIME *pDvrTime);
    
    static H264_DVR_TIME *ToH264_DVR_TIME(H264_DVR_TIME* pDvrTime,time_t t);
    
    static H264_DVR_TIME TRH264_DVR_TIME(int dwYear,int dwMonth,int dwDay,int dwHour,int dwMinute,int dwSecond);
};
