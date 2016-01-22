//
//  BbPatchGestureRecognizer.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbCoreViewProtocols.h"
#import "UIView+BbPatch.h"

@interface BbPatchGestureRecognizer : UIGestureRecognizer

@property (nonatomic,weak)                      id<BbEntityView,BbObjectView>    firstView;
@property (nonatomic,weak)                      id<BbEntityView,BbObjectView>    currentView;

@property (nonatomic)                           BbEntityViewType          firstViewType;
@property (nonatomic)                           BbEntityViewType          currentViewType;

@property (nonatomic)                           CGPoint             location;
@property (nonatomic)                           CGPoint             previousLocation;
@property (nonatomic)                           CGPoint             deltaLocation;

@property (nonatomic)                           CGPoint             position;
@property (nonatomic)                           CGPoint             previousPosition;
@property (nonatomic)                           CGPoint             deltaPosition;

@property (nonatomic)                           NSUInteger          numberOfTouches;
@property (nonatomic)                           NSUInteger          repeatCount;
@property (nonatomic)                           NSTimeInterval      duration;
@property (nonatomic)                           CGFloat             movement;

@property (nonatomic,getter=isTracking)         BOOL                tracking;

- (void)stopTracking;

@end
