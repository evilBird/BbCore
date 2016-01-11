//
//  BbBridge.h
//  BbBridge
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#ifndef BbBridge_h
#define BbBridge_h

#import <Foundation/Foundation.h>

@protocol BbObjectViewDataSource;

@protocol BbObjectView <NSObject>

- (void)removeFromSuperView;
- (void)addSubview:(id<BbObjectView>)view;
- (id)objectViewPosition:(id)sender;

@optional

- (id<BbObjectView>)initWithDataSource:(id<BbObjectViewDataSource>)dataSource;
- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;
- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

- (void)addConnectionWithPoints:(id)connection;
- (void)removeConnection:(id)connection;

@end

@protocol BbObjectViewDataSource <NSObject>

- (NSUInteger)numberOfInlets;
- (NSUInteger)numberOfOutlets;
- (NSString *)titleText;
- (NSValue *)initialPosition;
- (void)BbObjectView:(id<BbObjectView>)sender argumentsDidChange:(NSString *)arguments;
- (void)BbObjectView:(id<BbObjectView>)sender viewForPort:(id)port didMoveToIndex:(NSUInteger)index;

@end

#endif /* BbBridge_h */
