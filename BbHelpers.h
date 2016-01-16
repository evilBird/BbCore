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
+ (NSString *)position2String:(id)position;

+ (NSArray *)string2Array:(NSString *)string;
+ (NSArray *)string2DoubleArray:(NSString *)string;

+ (NSString *)getSelectorFromArray:(NSArray *)array;
+ (NSArray *)getArgumentsFromArray:(NSArray *)array;

+ (NSString *)doubleArrayToString:(NSArray *)doubleArray;

+ (NSValue *)positionFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)offsetFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)zoomScaleFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)sizeFromViewArgs:(NSString *)viewArgs;

+ (NSString *)updateViewArgs:(NSString *)viewArgs withPosition:(NSValue *)position;
+ (NSString *)updateViewArgs:(NSString *)viewArgs withOffset:(NSValue *)offset;
+ (NSString *)updateViewArgs:(NSString *)viewArgs withZoomScale:(NSValue *)zoomScale;
+ (NSString *)updateViewArgs:(NSString *)viewArgs withSize:(NSValue *)size;

@end
