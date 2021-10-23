//
//  ControlPlist.h
//  LutecCamera
//
//  Created by lhb on 2017/7/21.
//  Copyright © 2017年 lutec. All rights reserved.
//

#ifndef ControlPlist_h
#define ControlPlist_h

#import <Foundation/Foundation.h>

@interface ControlPlist : NSObject
+ (ControlPlist *)sharedInstance;
-(NSString*)getPlistPath;
-(BOOL) isPlistFileExists;
-(void)initPlist;
-(BOOL)isBookExistsForKey:(NSString *)key;
-(void)removeBookWithKey:(NSString *)key;
-(void)deletePlist;
-(void)writePlist:(NSMutableDictionary*)dictionary forKey:(NSString *)key;
-(NSMutableDictionary*)readPlist;
-(void)readPlist:(NSMutableDictionary **)dictionary;
-(void)replaceDictionary:(NSMutableDictionary *)newDictionary withDictionaryKey:(NSString *)key;
-(NSInteger)getBooksCount;
@end
#endif /* ControlPlist_h */
