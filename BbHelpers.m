//
//  BbHelpers.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbHelpers.h"
#import <UIKit/UIKit.h>

@implementation BbHelpers

+ (NSString *)createUniqueIDString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = NULL;
    if (uuid) {
        uuidString = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    NSString *uniqueIDString = (__bridge_transfer NSString *)uuidString;
    return uniqueIDString;
}

+ (NSArray *)string2Array:(NSString *)string
{
    if ( nil == string ) {
        return nil;
    }
    NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *aComponent in components ) {
        id argument = [BbHelpers stringComponent2Object:aComponent];
        if ( nil != argument ) {
            [temp addObject:argument];
        }
    }
    
    if ( temp.count ) {
        return [NSArray arrayWithArray:temp];
    }
    
    return nil;
}

+ (NSArray *)string2DoubleArray:(NSString *)string
{
    NSArray *array = [BbHelpers string2Array:string];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *aString in array ) {
        [result addObject:@([aString doubleValue])];
    }
    
    return result;
}

+ (NSString *)doubleArrayToString:(NSArray *)doubleArray
{
    NSMutableArray *formattedNumbers = [NSMutableArray arrayWithCapacity:doubleArray.count];
    for (NSNumber *aNumber in doubleArray) {
        [formattedNumbers addObject:[NSString stringWithFormat:@"%.4f",aNumber.doubleValue]];
    }
    
    return [formattedNumbers componentsJoinedByString:@" "];
}

+ (id)stringComponent2Object:(NSString *)string
{
    if ( nil == string ) {
        return nil;
    }
    
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( trimmed.length == 0 ) {
        return nil;
    }
    
    NSCharacterSet *decimalDigits = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSRange range = [trimmed rangeOfCharacterFromSet:decimalDigits options:0];
    if ( range.location == NSNotFound || range.length < trimmed.length ) {
        return trimmed; //Return as string
    }
    
    double doubleValue = [trimmed doubleValue];
    return @(doubleValue);

}

+ (NSString *)position2String:(id)position
{
    if ( nil == position ) {
        return @"0 0";
    }
    
    if ( [position isKindOfClass:[NSValue class] ]) {
        CGPoint point = [(NSValue *)position CGPointValue];
        CGFloat x = point.x;
        CGFloat y = point.y;
        return [NSString stringWithFormat:@"%.2f %.2f",x,y];
    }

    return @"0 0";
}

+ (NSValue *)positionFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    NSArray *args = [BbHelpers string2DoubleArray:viewArgs];
    if ( args.count != 2 ) {
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    return [NSValue valueWithCGPoint:CGPointMake([args.firstObject doubleValue], [args.lastObject doubleValue])];
}

+ (NSValue *)offsetFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    NSArray *args = [BbHelpers string2DoubleArray:viewArgs];
    if ( args.count < 4 ) {
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    return [NSValue valueWithCGPoint:CGPointMake([args[2] doubleValue], [args[3] doubleValue])];
}

+ (NSValue *)zoomScaleFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return (NSValue *)[NSNumber numberWithDouble:1.0];
    }
    
    NSArray *args = [BbHelpers string2DoubleArray:viewArgs];
    if ( args.count < 5 ) {
        return (NSValue *)[NSNumber numberWithDouble:1.0];
    }
    
    return (NSNumber *)[NSNumber numberWithDouble:[args.lastObject doubleValue]];
}

+ (NSValue *)sizeFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)];
    }
    
    NSArray *args = [BbHelpers string2DoubleArray:viewArgs];
    if ( args.count < 5 ) {
        return [NSValue valueWithCGSize:CGSizeMake(0.0, 0.0)];
    }
    
    return [NSValue valueWithCGSize:CGSizeMake([args[0] doubleValue], [args[1] doubleValue])];
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withPosition:(NSValue *)position
{
    if ( nil == viewArgs || nil == position ) {
        return viewArgs;
    }
    
    NSMutableArray *numberArray = [BbHelpers string2DoubleArray:viewArgs].mutableCopy;
    if ( numberArray.count < 2 ) {
        return viewArgs;
    }
    
    CGPoint point = position.CGPointValue;
    numberArray[0] = @(point.x);
    numberArray[1] = @(point.y);
    return [BbHelpers doubleArrayToString:numberArray];
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withOffset:(NSValue *)offset
{
    if ( nil == viewArgs || nil == offset ) {
        return viewArgs;
    }
    
    NSMutableArray *numberArray = [BbHelpers string2DoubleArray:viewArgs].mutableCopy;
    if ( numberArray.count < 4 ) {
        return viewArgs;
    }
    
    CGPoint point = offset.CGPointValue;
    numberArray[2] = @(point.x);
    numberArray[3] = @(point.y);
    return [BbHelpers doubleArrayToString:numberArray];
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withZoomScale:(NSValue *)zoomScale
{
    if ( nil == viewArgs || nil == zoomScale ) {
        return viewArgs;
    }
    
    NSMutableArray *numberArray = [BbHelpers string2DoubleArray:viewArgs].mutableCopy;
    if ( numberArray.count < 5 ) {
        return viewArgs;
    }
    
    CGFloat zoom = [(NSNumber *)zoomScale doubleValue];
    numberArray[4] = @(zoom);
    return [BbHelpers doubleArrayToString:numberArray];
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withSize:(NSValue *)size
{
    if ( nil == viewArgs || nil == size ) {
        return viewArgs;
    }
    
    NSMutableArray *numberArray = [BbHelpers string2DoubleArray:viewArgs].mutableCopy;
    if ( numberArray.count < 5 ) {
        return viewArgs;
    }
    
    CGSize newSize = size.CGSizeValue;
    numberArray[0] = @(newSize.width);
    numberArray[1] = @(newSize.height);
    return [BbHelpers doubleArrayToString:numberArray];
}

@end
