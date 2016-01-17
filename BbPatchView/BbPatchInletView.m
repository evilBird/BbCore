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
    [self addConstraint:[outletView pinEdge:LayoutEdge_Top toSuperviewEdge:LayoutEdge_Top]];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(kPatchInletViewWidth, kPatchInletViewHeight);
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
