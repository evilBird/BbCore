//
//  BbPatch+BbObjectViewDataSource.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPatch.h"

@implementation BbPatch (BbObjectViewDataSource)

- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView
{
    return [BbHelpers positionFromViewArgs:nil];
}

- (NSValue *)contentOffsetForObjectView:(id<BbObjectView>)objectView
{
    return [BbHelpers offsetFromViewArgs:self.viewArguments];
}

- (NSValue *)zoomScaleForObjectView:(id<BbObjectView>)objectView
{
    return [BbHelpers zoomScaleFromViewArgs:self.viewArguments];
}

- (NSValue *)sizeForObjectView:(id<BbObjectView>)objectView
{
    return [BbHelpers sizeFromViewArgs:self.viewArguments];
}

- (BOOL)objectView:(id<BbObjectView>)sender canOpenChildView:(id<BbObjectView>)child
{
    return NO;
}

- (BOOL)objectView:(id<BbObjectView>)sender canOpenHelpObjectForChildView:(id<BbObjectView>)child
{
    return NO;
}

- (BOOL)objectView:(id<BbObjectView>)sender canTestObjectForChildView:(id<BbObjectView>)child
{
    return NO;
}

@end
