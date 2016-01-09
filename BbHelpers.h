//
//  BbHelpers.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BbHelpers : NSObject

+ (NSString *)createUniqueIDString;
+ (NSArray *)string2Array:(NSString *)string;
+ (NSString *)position2String:(id)position;

@end
