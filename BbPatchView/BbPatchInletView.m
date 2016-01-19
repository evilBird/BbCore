//
//  BbPatchInletView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchInletView.h"

@implementation BbPatchInletView

- (void)setupPrimaryContentView {}

- (void)setupInletViews {}

- (void)setupOutletViews
{
    self.outletViews = [self makeOutletViews:1];
    BbOutletView *outletView = self.outletViews.firstObject;
    [self addSubview:outletView];
    [self addConstraint:[outletView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self addConstraint:[outletView pinEdge:LayoutEdge_Bottom toSuperviewEdge:LayoutEdge_Bottom]];
}

- (CGSize)intrinsicContentSize
{
    CGSize portSize = [BbPortView defaultPortViewSize];
    return CGSizeMake(portSize.width*3, portSize.width*3);
}

- (void)calculateSpacingAndContentSize
{
    CGSize portSize = [BbPortView defaultPortViewSize];
    self.myContentSize = CGSizeMake(portSize.width*3, portSize.width*3);
    [self invalidateIntrinsicContentSize];
}

- (void)updateAppearance
{
    if ( self.selected ) {
        
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        
    }else{
        
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
    }
    self.backgroundColor = self.myFillColor;
    self.layer.borderColor = self.myBorderColor.CGColor;
    self.layer.borderWidth = 1.0;
    [self invalidateIntrinsicContentSize];
    //[self layoutIfNeeded];
    [self setNeedsDisplay];
}

- (BOOL)canEdit
{
    return NO;
}

- (BOOL)canReload
{
    return NO;
}

@end
