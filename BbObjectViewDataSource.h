//
//  BbObjectViewDataSource.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbObjectViewDataSource_h
#define BbObjectViewDataSource_h

@protocol BbObjectViewDataSource <NSObject>

- (NSUInteger)numberOfInletsForObjectView:(id<BbObjectView>)objectView;
- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView;

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView;
- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView;

- (void)objectView:(id<BbObjectView>)sender positionDidChange:(NSValue *)position;
- (void)objectView:(id<BbObjectView>)sender objectArgumentsDidChange:(NSString *)arguments;

@optional

- (NSValue *)contentOffsetForObjectView:(id<BbObjectView>)objectView;
- (NSValue *)zoomScaleForObjectView:(id<BbObjectView>)objectView;
- (NSValue *)sizeForObjectView:(id<BbObjectView>)objectView;

- (void)objectView:(id<BbObjectView>)sender objectClassDidChange:(NSString *)objectClass arguments:(NSString *)arguments;
- (void)objectView:(id<BbObjectView>)sender doAction:(id)anAction withArguments:(id)arguments;
- (void)objectView:(id<BbObjectView>)sender contentOffsetDidChange:(NSValue *)offset;
- (void)objectView:(id<BbObjectView>)sender zoomScaleDidChange:(NSValue *)zoomScale;
- (void)objectView:(id<BbObjectView>)sender sizeDidChange:(NSValue *)viewSize;
- (void)objectView:(id<BbObjectView>)sender viewForPort:(id)port didMoveToIndex:(NSUInteger)index;

@end

#endif /* BbObjectViewDataSource_h */
