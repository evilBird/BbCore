//
//  UIView+BbPatch.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "UIView+BbPatch.h"

@implementation UIView (BbPatch)

CGPoint CGPointGetOffset(CGPoint point, CGPoint referencePoint)
{
    CGFloat dx = point.x-referencePoint.x;
    CGFloat dy = point.y-referencePoint.y;
    return CGPointMake(dx, dy);
}

CGFloat CGPointGetDistance(CGPoint point, CGPoint referencePoint)
{
    CGPoint offset = CGPointGetOffset(point, referencePoint);
    return sqrt((offset.x * offset.x)+(offset.y * offset.y));
}


- (CGPoint)point2Position:(CGPoint)point
{
    CGRect bounds = self.superview.bounds;
    if ( CGRectIsEmpty(bounds) ) {
        return CGPointZero;
    }
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint offset;
    offset.x = point.x-center.x;
    offset.y = point.y-center.y;
    CGPoint position;
    position.x = offset.x/(CGRectGetWidth(bounds)/2.0);
    position.y = offset.y/(CGRectGetHeight(bounds)/2.0);
    
    return position;
}

- (CGPoint)point2Offset:(CGPoint)point
{
    CGRect bounds = self.superview.bounds;
    if ( CGRectIsEmpty(bounds) ) {
        return CGPointZero;
    }
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint offset;
    offset.x = point.x-center.x;
    offset.y = point.y-center.y;
    return offset;
}

- (CGPoint)position2Offset:(CGPoint)position
{
    CGRect bounds = self.superview.bounds;
    if ( CGRectIsEmpty(bounds) ) {
        return CGPointZero;
    }
    
    CGPoint offset;
    offset.x = position.x * (CGRectGetWidth(bounds)/2.0);
    offset.y = position.y * (CGRectGetHeight(bounds)/2.0);
    return offset;
}

@end
