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

+ (NSValue *)positionFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)offsetFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)zoomScaleFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)sizeFromViewArgs:(NSString *)viewArgs;

+ (NSString *)updateViewArgs:(NSString *)viewArgs withPosition:(NSValue *)position;
+ (NSString *)updateViewArgs:(NSString *)viewArgs withOffset:(NSValue *)offset;
+ (NSString *)updateViewArgs:(NSString *)viewArgs withZoomScale:(NSValue *)zoomScale;
+ (NSString *)updateViewArgs:(NSString *)viewArgs withSize:(NSValue *)size;

@end
