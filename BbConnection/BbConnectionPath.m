//
//  BbConnectionPath.m
//  Pods
//
//  Created by Travis Henspeter on 1/21/16.
//
//

#import "BbConnectionPath.h"
#import <UIKit/UIKit.h>

@interface BbConnectionPath ()

@property (nonatomic,strong)        UIColor                 *selectedColor;
@property (nonatomic,strong)        UIColor                 *defaultColor;
@property (nonatomic,strong)        UIBezierPath            *myBezierPath;

@end

@implementation BbConnectionPath

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.myBezierPath = [UIBezierPath bezierPath];
    self.needsRedraw = YES;
    self.valid = NO;
    self.entity = nil;
    self.selected = nil;
    self.defaultColor = [UIColor blackColor];
    self.selectedColor = [UIColor colorWithWhite:0.3 alpha:1.0];
}

- (id)bezierPath
{
    if ( !self.needsRedraw ) {
        return self.myBezierPath;
    }
    
    [self.myBezierPath removeAllPoints];
    [self.myBezierPath moveToPoint:self.startPoint.CGPointValue];
    [self.myBezierPath addLineToPoint:self.endPoint.CGPointValue];
    return self.myBezierPath;
}

- (id)color
{
    if ( self.isSelected ) {
        return self.selectedColor;
    }
    
    return self.defaultColor;
}

- (NSValue *)centerPointValueForEntityView:(id<BbEntityView>)view inParentView:(id<BbEntityView>)parentView
{
    UIView *portView = (UIView *)view;
    UIView *patchView = (UIView *)parentView;
    CGPoint point = [patchView convertPoint:portView.center fromView:portView.superview];
    return [NSValue valueWithCGPoint:point];
}

- (void)dealloc
{
    [_myBezierPath removeAllPoints];
    _myBezierPath = nil;
}

@end
