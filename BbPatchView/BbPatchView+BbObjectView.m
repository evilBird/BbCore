//
//  BbPatchView+BbObjectView.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbPatchView.h"

@implementation BbPatchView (BbObjectView)

- (void)updateLayout
{
    for (id<BbObjectView> objectView in self.childViews.allObjects ) {
        [objectView updateLayout];
    }
    
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    BbPatchView *patchView = [[BbPatchView alloc]initWithDataSource:dataSource];
    return patchView;
}

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index
{
    return nil;
}

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index
{
    return nil;
}

- (void)addChildObjectView:(id<BbObjectView>)view
{
    if ( [self.childViews containsObject:view] ) {
        return;
    }
    [self.childViews addObject:view];
    [self addSubview:(UIView *)view];
    [self addConstraints:[view positionConstraints]];
    [view updateLayout];
}

- (void)removeChildObjectView:(id<BbObjectView>)view
{
    if ( ![self.childViews containsObject:view] ) {
        return;
    }
    
    [self.childViews removeObject:view];
    [view removeFromSuperView];
}

- (void)setSizeWithValue:(NSValue *)value
{
    [self.eventDelegate patchView:self didChangeSize:value];
}

- (void)setZoomScaleWithValue:(NSValue *)value
{
    [self.eventDelegate patchView:self didChangeZoomScale:value];
}

- (void)setContentOffsetWithValue:(NSValue *)value
{
    [self.eventDelegate patchView:self didChangeContentOffset:value];
}

@end
