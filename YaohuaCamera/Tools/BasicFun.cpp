//
//  SDKBasicFun.m
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

#include "BasicFun.h"


/**
 *  时间转换处理
 *
 *  @param pDvrTime SDK系统时间
 *
 *  @return
 */
time_t BasicFun::ToTime_t(SDK_SYSTEM_TIME *pDvrTime) {
    struct tm t = {0};
    t.tm_year   = pDvrTime->year - 1900;
    t.tm_mon    = pDvrTime->month - 1;
    t.tm_mday   = pDvrTime->day;
    t.tm_hour   = pDvrTime->hour;
    t.tm_min    = pDvrTime->minute;
    t.tm_sec    = pDvrTime->second;
    return mktime(&t);
}

time_t BasicFun::ToTime_t(H264_DVR_TIME *pDvrTime){
    struct tm t = {0};
    t.tm_year   = pDvrTime->dwYear - 1900;
    t.tm_mon    = pDvrTime->dwMonth - 1;
    t.tm_mday   = pDvrTime->dwDay;
    t.tm_hour   = pDvrTime->dwHour;
    t.tm_min    = pDvrTime->dwMinute;
    t.tm_sec    = pDvrTime->dwSecond;
    return mktime(&t);
}

H264_DVR_TIME* BasicFun::ToH264_DVR_TIME(H264_DVR_TIME* pDvrTime,time_t t) {
    struct tm *p       = localtime(&t);
    pDvrTime->dwYear   = p->tm_year + 1900;
    pDvrTime->dwMonth  = p->tm_mon + 1;
    pDvrTime->dwDay    = p->tm_mday;
    pDvrTime->dwHour   = p->tm_hour;
    pDvrTime->dwMinute = p->tm_min;
    pDvrTime->dwSecond = p->tm_sec;
    return pDvrTime;
}

///**
// *  转换到H264_DVR_TIME
// *
// *  @return H264_DVR_TIME数组
// */
//
H264_DVR_TIME BasicFun::TRH264_DVR_TIME(int dwYear,int dwMonth,int dwDay,int dwHour,int dwMinute,int dwSecond) {
    H264_DVR_TIME time;
    time.dwYear = dwYear;
    time.dwMonth = dwMonth;
    time.dwDay = dwDay;
    time.dwHour = dwHour;
    time.dwMinute = dwMinute;
    time.dwSecond = dwSecond;
    return time;
}

