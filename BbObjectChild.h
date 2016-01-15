//
//  BbObjectChild.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbObjectChild_h
#define BbObjectChild_h

#import <Foundation/Foundation.h>

@protocol BbObjectView;
@protocol BbObjectParent;

@protocol BbObject <NSObject>

@property (nonatomic,strong)        NSString                *uniqueID;
@property (nonatomic,strong)        NSHashTable             *observers;

@optional

- (BOOL)startObservingObject:(id<BbObject>)object;
- (BOOL)stopObservingObject:(id<BbObject>)object;
- (BOOL)addObjectObserver:(id<BbObject>)object;
- (BOOL)removeObjectObserver:(id<BbObject>)object;
- (BOOL)removeAllObjectObservers;

@end

@protocol BbObjectChild <NSObject,BbObject>

@property (nonatomic,weak)          id<BbObjectParent>      parent;
@property (nonatomic,strong)        id<BbObjectView>        view;

- (NSUInteger)indexInParent;

@optional

- (void)willBeRemovedFromParent:(id<BbObjectParent>)parent;
- (BOOL)startObserving:(id<BbObjectChild>)object;
- (NSString *)textDescription;
- (void)loadView;

@end

#endif /* BbObjectChild_h */
