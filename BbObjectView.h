//
//  BbObjectView.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbObjectView_h
#define BbObjectView_h

#import "BbBridge.h"

@protocol BbObjectView <NSObject>

- (void)removeFromSuperView;
- (void)addSubview:(id<BbObjectView>)view;
- (id)objectViewPosition:(id)sender;

@optional

- (id<BbObjectView>)initWithDataSource:(id<BbObjectViewDataSource>)dataSource;
- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;
- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

@end

#endif /* BbObjectView_h */
