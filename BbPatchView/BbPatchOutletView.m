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
    return CGSizeMake(kPatchOutletViewWidth, kPatchOutletViewHeight);
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
