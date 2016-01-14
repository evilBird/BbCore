//
//  BbBoxView+BbObjectView.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbBoxView.h"

@implementation BbBoxView (BbObjectView)

#pragma mark - BbObjectView

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    return [[BbBoxView alloc]initWithDataSource:dataSource];
}

- (void)setTitleText:(NSString *)titleText
{
    [self setTitle:titleText];
}

- (void)setPositionWithValue:(NSValue *)value
{
    CGPoint position = [value CGPointValue];
    [self setPosition:position];
}

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index
{
    if ( nil == self.inletViews || index >= self.inletViews.count ) {
        return nil;
    }
    
    return self.inletViews[index];
}

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index
{
    if ( nil == self.outletViews || index >= self.outletViews.count ) {
        return nil;
    }
    
    return self.outletViews[index];
}

- (void)setDataSource:(id<BbObjectViewDataSource>)dataSource reloadViews:(BOOL)reload
{
    if ( reload ) {
        [self reloadViewsWithDataSource:dataSource];
    }
}

- (void)doAction:(void(^)(void))action
{
    
}

- (void)suggestTextCompletion:(id)textCompletion
{
    
}

@end
