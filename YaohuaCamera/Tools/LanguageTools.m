//
//  LanguageTools.m
//  Created by Luhongbin on 2017/6/22.
//  Copyright © 2017年 com.cnymec.Camera. All rights reserved.
//

#import "LanguageTools.h"

@implementation LanguageTools


+ (NSString *)XMLocalizedString:(NSString *)translation_key {
    NSString * s = [[NSBundle mainBundle] localizedStringForKey:(translation_key) value:@"" table:nil];
    if (![self checkSystemCurrentLanguageIsEnglish] && ![self checkSystemCurrentLaguageIsChinese])                                                                            {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle * languageBundle = [NSBundle bundleWithPath:path];
        s = [languageBundle localizedStringForKey:translation_key value:@"" table:nil];
    }
    return s;
}

+ (BOOL)checkSystemCurrentLanguageIsEnglish
{
    const NSString *englist = @"en-CN";
    NSString *currentLanguage = [self getIOSSystemCurrentLanguage];
    if ([englist isEqualToString:currentLanguage]) {
        return true;
    }else{
        return false;
    }
}

+ (NSArray *)getIOSSystemSupportLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 取得 iPhone 支持的所有语言设置
    NSArray *languages = [defaults objectForKey : @"AppleLanguages" ];
    return languages;
}                                                                               

+ (NSString *)getPreferredLanguage
{
    NSArray *languages = [self getIOSSystemSupportLanguage];
    return [languages firstObject];
}

+ (NSString *)getIOSSystemCurrentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    return [languages objectAtIndex:0];
}


+ (BOOL)checkSystemCurrentLanguageIsSimplifiedChinese
{
    const NSArray *languageTargs = @[@"zh-Hans",@"zh-Hans-CN",@"da-CN"];
    NSString *currentLanguage = [self getIOSSystemCurrentLanguage];
    
    for (NSString *languageTarg in languageTargs) {
        if ([languageTarg isEqualToString:currentLanguage]) {
            return true;
        }
    }

    return false;
}


+ (BOOL)checkSystemCurrentLanguageIsTraditionalChinese
{
    const NSArray *languageTargs = @[@"zh-Hant",@"zh-Hans-TW",@"zh-Hant-CN",@"zh-TW",@"zh-HK"];
    NSString *currentLanguage = [self getIOSSystemCurrentLanguage];
    
    for (NSString *languageTarg in languageTargs) {
        if ([languageTarg isEqualToString:currentLanguage]) {
            return true;
        }
    }
    
    return false;
}

+ (BOOL)checkSystemCurrentLaguageIsChinese
{
    if ([self checkSystemCurrentLanguageIsSimplifiedChinese] || [self checkSystemCurrentLanguageIsTraditionalChinese]) {
        return true;
    }else{
        return false;
    }
}

+ (BOOL)SystemCurrentLanguageNotChinese
{
    return ![self checkSystemCurrentLaguageIsChinese];
}


@end
