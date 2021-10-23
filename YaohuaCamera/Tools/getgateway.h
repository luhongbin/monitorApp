//
//  getgateway.h
//  NetTest
//
//  Created by hzjf on 14-7-4.
//  Copyright (c) 2014年 hzjf. All rights reserved.
//

#ifndef __GETGATEWAY_H__
#define __GETGATEWAY_H__

/* getdefaultgateway() :
 * return value :
 *    0 : success
 *   -1 : failure    */
int getdefaultgateway(in_addr_t * addr);
char *IP2Str(int ip, char *szIP);
#endif