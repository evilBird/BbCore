//
//  BbPatchGestureRecognizer.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BbPatchGestureRecognizer : UIGestureRecognizer

@property (nonatomic,weak)                      UIView          *firstView;
@property (nonatomic,weak)                      UIView          *currentView;
@property (nonatomic,weak)                      UIView          *lastView;

@property (nonatomic)                           CGPoint         location;
@property (nonatomic)                           CGPoint         previousLocation;
@property (nonatomic)                           CGPoint         deltaLocation;

@property (nonatomic)                           CGPoint         position;
@property (nonatomic)                           CGPoint         previousPosition;
@property (nonatomic)                           CGPoint         deltaPosition;

@property (nonatomic)                           NSUInteger      numberOfTouches;
@property (nonatomic)                           NSUInteger      repeatCount;
@property (nonatomic)                           NSTimeInterval  duration;
@property (nonatomic)                           CGFloat         movement;

@property (nonatomic,getter=isTracking)         BOOL            tracking;

- (void)stopTracking;

@end
