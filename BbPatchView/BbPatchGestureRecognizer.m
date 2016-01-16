//
//  BbPatchGestureRecognizer.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UIView+BbPatch.h"

static NSTimeInterval kCountAsRepeatMaxDuration = 0.2;

@interface BbPatchGestureRecognizer ()

@property (nonatomic,strong)            NSDate          *firstTouchDate;
@property (nonatomic,strong)            NSDate          *previousFirstTouchDate;

@end

@implementation BbPatchGestureRecognizer


- (CGPoint)locationOfTouches:(NSSet<UITouch *> *)touches
{
    CGPoint sum = CGPointZero;
    NSUInteger numTouches = touches.allObjects.count;
    
    for ( NSUInteger i = 0 ; i < numTouches ; i ++ ) {
        CGPoint loc = [self locationOfTouch:i inView:self.view];
        sum.x += loc.x;
        sum.y += loc.y;
    }
    CGFloat multiplier = 1.0/(CGFloat)numTouches;
    sum.x*=multiplier;
    sum.y*=multiplier;
    return sum;
}

- (void)stopTracking
{
    self.tracking = NO;
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.tracking = YES;
    self.previousFirstTouchDate = self.firstTouchDate;
    self.firstTouchDate = [NSDate date];
    
    if ( nil == self.previousFirstTouchDate ) {
        self.repeatCount = 0;
    }else{
        NSTimeInterval timeSincePreviousFirst = [self.firstTouchDate timeIntervalSinceDate:self.previousFirstTouchDate];
        self.repeatCount = ( timeSincePreviousFirst < kCountAsRepeatMaxDuration ) ? ( self.repeatCount + 1 ) : ( 0 );
    }
    
    self.duration = 0.0;
    self.location = [self locationOfTouches:touches];
    self.previousLocation = self.location;
    self.movement = 0.0;
    self.numberOfTouches = touches.allObjects.count;
    self.firstView = [self.view hitTest:self.location withEvent:event];
    self.currentView = self.firstView;
    self.lastView = nil;
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.tracking = YES;
    self.duration = [[NSDate date] timeIntervalSinceDate:self.firstTouchDate];
    self.location = [self locationOfTouches:touches];
    self.movement += fabs(CGPointGetDistance(self.location, self.previousLocation));
    self.numberOfTouches = touches.allObjects.count;
    self.currentView =  [self.view hitTest:self.location withEvent:event];
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.tracking = NO;
    self.duration = [[NSDate date] timeIntervalSinceDate:self.firstTouchDate];
    self.location = [self locationOfTouches:touches];
    self.numberOfTouches = touches.allObjects.count;
    self.currentView = [self.view hitTest:self.location withEvent:event];
    self.lastView = self.currentView;
    self.state = UIGestureRecognizerStateEnded;
}

- (void)setLocation:(CGPoint)location
{
    _previousLocation = _location;
    _previousPosition = _position;
    _location = location;
    _position = CGPointGetOffset(location, self.view.center);
}

- (CGPoint)deltaLocation
{
    if ( CGPointEqualToPoint(self.previousLocation, CGPointZero) ) {
        return CGPointZero;
    }
    
    return CGPointMake((self.location.x-self.previousLocation.x), (self.location.y-self.previousLocation.y));
}

- (CGPoint)deltaPosition
{
    return CGPointMake((self.position.x-self.previousPosition.x), (self.position.y-self.previousPosition.y));
}

@end
