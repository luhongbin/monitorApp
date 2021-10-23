//
//  webservice.h
//  LutecCamera
//
//  Created by lhb on 2017/8/21.
//  Copyright © 2017年 lutec. All rights reserved.
//

#ifndef webservice_h
#define webservice_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//需要有两个Delegate，一个是解析XML用的，一个是网络连接用的；
@interface webservice : NSObject<NSXMLParserDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *webData;
@property (strong, nonatomic) NSMutableString *soapResults;
@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong, nonatomic) NSString *matchingElement;
@property (strong, nonatomic) NSURLConnection *conn;

-(void)query:(NSString*)phoneNumber;//在头文件中声明查询方法；

@end

#endif /* webservice_h */
