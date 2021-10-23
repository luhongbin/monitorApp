//
//  getgateway.c
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

#include <stdio.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include "getgateway.h"
#include "route.h"
#include <net/if.h>
#include <string.h>

#define CTL_NET         4               /* network, see socket.h */

#if defined(BSD) || defined(__APPLE__)

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))

int getdefaultgateway(in_addr_t * addr)
{
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS,  0x2};      /* destination is a gateway RTF_GATEWAY    0x2   */
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[8];    /* size of array to allocate RTAX_MAX    8 */
    int i;
    int r = -1;
    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        return -1;
    }
    if(l>0) {
        buf = (char *)malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            free(buf);
            return -1;
        }
        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++) {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;//
                }
            }
            
            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (0x1|0x2))        /* gateway sockaddr present RTA_GATEWAY    0x2 *//* destination sockaddr present RTA_DST        0x1*/
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                
                
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    char ifName[128];
                    if_indextoname(rt->rtm_index,ifName);
                    
                    if(strcmp("en0",ifName)==0){
                        
                        *addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                        r = 0;
                    }
                }
            }
        }
        free(buf);
    }
    return r;
}

char *IP2Str(int ip, char *szIP)
{
    int addr[4];
    for(int i = 0; i < 4; ++i)
    {
        addr[i] = (ip >> (i * 8)) & 0xFF;
    }
    sprintf(szIP, "%d.%d.%d.%d",addr[0], addr[1], addr[2], addr[3]);
    return szIP;
}
#endif
