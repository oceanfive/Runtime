//
//  ArchivedObject.m
//  Rumtime
//
//  Created by wuhaiyang on 16/8/24.
//  Copyright © 2016年 wuhaiyang. All rights reserved.
//

#import "ArchivedObject.h"
#import <objc/runtime.h>

@implementation ArchivedObject


- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([ArchivedObject class], &count); //获取所有的成员变量
    for (int i = 0; i < count; i++) {    //遍历所有的成员变量
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);  //获取成员变量名称
        NSString *key = [NSString stringWithUTF8String:name];  //以成员变量作为key值
        id value = [self valueForKey:key];  //键值对获取value值
        [aCoder encodeObject:value forKey:key];  //归档
    }
    free(ivars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([ArchivedObject class], &count); //获取所有的成员变量
        for (int i = 0; i < count; i++) { //遍历所有的成员变量
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar); //获取成员变量名称
            NSString *key = [NSString stringWithUTF8String:name]; //以成员变量作为key值
            id value = [aDecoder decodeObjectForKey:key]; //反归档
            [self setValue:value forKey:key]; //键值对获取value值
        }
        free(ivars);
    }
    return self;
}


@end
