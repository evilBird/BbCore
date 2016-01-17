//
//  UIView+BbPatch.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbObjectView.h"

@interface UIView (BbPatch)

CGPoint CGPointGetOffset(CGPoint point, CGPoint referencePoint);
CGFloat CGPointGetDistance(CGPoint point, CGPoint referencePoint);

- (CGPoint)point2Position:(CGPoint)point;
- (CGPoint)point2Offset:(CGPoint)point;
- (CGPoint)position2Offset:(CGPoint)position;
- (CGPoint)position2Point:(CGPoint)position;
- (CGPoint)offset2Point:(CGPoint)offset;
- (CGSize)multiplySize:(CGSize)size1 withSize:(CGSize)size2;

- (BbViewType)myViewType;

@end
