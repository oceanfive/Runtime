//
//  ArchivedObject.h
//  Rumtime
//
//  Created by wuhaiyang on 16/8/24.
//  Copyright © 2016年 wuhaiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchivedObject : NSObject<NSCoding>

@property (nonatomic, assign) int age;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) double height;

@end
