//
//  BbPatchOutletView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchOutletView.h"

@implementation BbPatchOutletView

- (void)setupPrimaryContentView {}

- (void)setupInletViews {

    self.inletViews = [self makeInletViews:1];
    BbInletView *inletView = self.inletViews.firstObject;
    [self addSubview:inletView];
    [self addConstraint:[inletView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self addConstraint:[inletView pinEdge:LayoutEdge_Bottom toSuperviewEdge:LayoutEdge_Bottom]];
}

- (CGSize)intrinsicContentSize
{
    CGSize portSize = [BbPortView defaultPortViewSize];
    return CGSizeMake(portSize.width*3, portSize.width*3);
}

- (void)setupOutletViews {}

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
