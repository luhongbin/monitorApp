//
//  LanguageTools.h
//  XMEye
//
//  Created by Wangchaoqun on 15/11/13.
//  Copyright © 2015年 Megatron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageTools : NSObject

/*!
 @method
 @abstract    获取系统所支持的所有语言
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      语言数组
 */
+ (NSArray *)getIOSSystemSupportLanguage;

/*!
 @method
 @abstract    获取系统所支持的首选语言
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      首选语言
 */
+ (NSString *)getPreferredLanguage;

/*!
 @method
 @abstract    获取当前使用的语言
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      当前语言
 */
+ (NSString *)getIOSSystemCurrentLanguage;

/*!
 @method
 @abstract    判断中文
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      是否为中文
 */
+ (BOOL)checkSystemCurrentLaguageIsChinese;

/*!
 @method
 @abstract    判断是否为简体中文
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      是否为简体中文
 */
+ (BOOL)checkSystemCurrentLanguageIsSimplifiedChinese;

/*!
 @method
 @abstract    判断繁体中文
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      是否为繁体中文
 */
+ (BOOL)checkSystemCurrentLanguageIsTraditionalChinese;

/*!
 @method
 @abstract    判断中文
 @discussion  静态类
 @param text  无参数
 @param error 无错误值
 @result      是否为中文
 */
+ (BOOL)SystemCurrentLanguageNotChinese;

/*
 @method
 @abstract   默认英文字符
 @discussion 静态类
 @param text 
 @param error 无错误值
 @result      
 */
+ (NSString *)XMLocalizedString:(NSString *)translation_key;

@end
