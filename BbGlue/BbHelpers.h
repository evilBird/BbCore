//
//  BbHelpers.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BbHelpers : NSObject


+ (NSString *)getSelectorFromArray:(NSArray *)array;
+ (NSArray *)getArgumentsFromArray:(NSArray *)array;

+ (NSValue *)positionFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)offsetFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)zoomScaleFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)sizeFromViewArgs:(NSString *)viewArgs;


@end
