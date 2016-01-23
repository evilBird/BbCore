//
//  BbHelpers.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbHelpers.h"
#import "BbCoreProtocols.h"
#import <UIKit/UIKit.h>

@implementation BbHelpers

+ (NSString *)getSelectorFromArray:(NSArray *)array
{
    if ( nil == array ) {
        return nil;
    }
    
    id first = array.firstObject;
    
    if ( [first isKindOfClass:[NSString class]] ) {
        return first;
    }
    
    return nil;
}

+ (NSArray *)getArgumentsFromArray:(NSArray *)array
{
    if ( nil == array || array.count < 2 ) {
        return nil;
    }
    NSMutableArray *copy = array.mutableCopy;
    [copy removeObjectAtIndex:0];
    
    return [NSArray arrayWithArray:copy];
}

+ (NSString *)viewArgsFromSize:(NSValue *)size
{
    if ( nil == size ) {
        return @"2.0 2.0";
    }
    
    CGSize s = size.CGSizeValue;
    return [NSString stringWithFormat:@"%.2f %.2f",s.width,s.height];
}

+ (NSString *)viewArgsFromContentOffset:(NSValue *)offset
{
    if ( nil == offset ) {
        return @"0.0 0.0";
    }
    CGPoint off = offset.CGPointValue;
    return [NSString stringWithFormat:@"%.3f %.3f",off.x,off.y];
}

+ (NSString *)viewArgsFromZoomScale:(NSValue *)zoom
{
    if ( nil == zoom ) {
        return @"0.0";
    }
    
    double z = [(NSNumber *)zoom doubleValue];
    return [NSString stringWithFormat:@"%.2f",z];
}

+ (NSString *)viewArgsFromPosition:(NSValue *)position
{
    if ( nil == position ) {
        return @"0.0 0.0";
    }
    CGPoint point = position.CGPointValue;
    return [NSString stringWithFormat:@"%.3f %.3f",point.x,point.y];
}

+ (NSValue *)positionFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    NSArray *args = [viewArgs getArguments];
    if ( args.count < ( kViewArgumentIndexPosition_Y + 1 ) ) {
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    return [NSValue valueWithCGPoint:CGPointMake([args[kViewArgumentIndexPosition_X] doubleValue], [args[kViewArgumentIndexPosition_Y] doubleValue])];
}

+ (NSValue *)offsetFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    NSArray *args = [viewArgs getArguments];
    if ( args.count < ( kViewArgumentIndexContentOffset_Y + 1 ) ) {
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    return [NSValue valueWithCGPoint:CGPointMake([args[kViewArgumentIndexContentOffset_X] doubleValue], [args[kViewArgumentIndexContentOffset_Y] doubleValue])];
}

+ (NSValue *)zoomScaleFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return (NSValue *)[NSNumber numberWithDouble:1.0];
    }
    
    NSArray *args = [viewArgs getArguments];
    if ( args.count < ( kViewArgumentIndexZoomScale + 1 ) ) {
        return (NSValue *)[NSNumber numberWithDouble:1.0];
    }
    
    return (NSNumber *)[NSNumber numberWithDouble:[args[kViewArgumentIndexZoomScale] doubleValue]];
}

+ (NSValue *)sizeFromViewArgs:(NSString *)viewArgs
{
    if ( nil == viewArgs ){
        return [NSValue valueWithCGSize:CGSizeMake(2.0, 2.0)];
    }
    
    NSArray *args = [viewArgs getArguments];
    if ( args.count < (kViewArgumentIndexSize_Height + 1) ) {
        return [NSValue valueWithCGSize:CGSizeMake(2.0, 2.0)];
    }
    
    return [NSValue valueWithCGSize:CGSizeMake([args[kViewArgumentIndexSize_Width] doubleValue], [args[kViewArgumentIndexSize_Height] doubleValue])];
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withPosition:(NSValue *)position
{
    if ( nil == viewArgs || nil == position || [viewArgs numberOfArguments] < ( kViewArgumentIndexPosition_Y + 1 ) ) {
        return viewArgs;
    }
    
    CGPoint point = position.CGPointValue;
    viewArgs = [viewArgs setArgument:@(point.x) atIndex:kViewArgumentIndexPosition_X];
    viewArgs = [viewArgs setArgument:@(point.y) atIndex:kViewArgumentIndexPosition_Y];
    return viewArgs;
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withOffset:(NSValue *)offset
{
    if ( nil == viewArgs || nil == offset || [viewArgs numberOfArguments] < (kViewArgumentIndexContentOffset_Y + 1) ) {
        return viewArgs;
    }
    CGPoint point = offset.CGPointValue;
    viewArgs = [viewArgs setArgument:@(point.x) atIndex:kViewArgumentIndexContentOffset_X];
    viewArgs = [viewArgs setArgument:@(point.y) atIndex:kViewArgumentIndexContentOffset_Y];
    return viewArgs;
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withZoomScale:(NSValue *)zoomScale
{
    if ( nil == viewArgs || nil == zoomScale || [viewArgs numberOfArguments] < (kViewArgumentIndexZoomScale + 1 ) ) {
        return viewArgs;
    }

    CGFloat zoom = [(NSNumber *)zoomScale doubleValue];
    viewArgs = [viewArgs setArgument:@(zoom) atIndex:kViewArgumentIndexZoomScale];
    return viewArgs;
}

+ (NSString *)updateViewArgs:(NSString *)viewArgs withSize:(NSValue *)size
{
    if ( nil == viewArgs || nil == size || [viewArgs numberOfArguments] < ( kViewArgumentIndexSize_Height + 1 )) {
        return viewArgs;
    }
    
    CGSize newSize = size.CGSizeValue;
    viewArgs = [viewArgs setArgument:@(newSize.width) atIndex:kViewArgumentIndexSize_Width];
    viewArgs = [viewArgs setArgument:@(newSize.height) atIndex:kViewArgumentIndexSize_Height];
    return viewArgs;
}

@end
