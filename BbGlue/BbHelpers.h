//
//  BbHelpers.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BbHelpers : NSObject


+ (NSString *)stringWithFormat:(NSString *)formatString arguments:(NSArray *)arguments;
+ (NSString *)stringWithFormatAndArgs:(NSArray *)formatAndArgs;

+ (NSString *)getSelectorFromArray:(NSArray *)array;
+ (NSArray *)getArgumentsFromArray:(NSArray *)array;

+ (NSString *)viewArgsFromPosition:(NSValue *)position;
+ (NSString *)viewArgsFromContentOffset:(NSValue *)offset;
+ (NSString *)viewArgsFromZoomScale:(NSValue *)zoom;
+ (NSString *)viewArgsFromSize:(NSValue *)size;

+ (NSValue *)positionFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)offsetFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)zoomScaleFromViewArgs:(NSString *)viewArgs;
+ (NSValue *)sizeFromViewArgs:(NSString *)viewArgs;


@end
