//
//  BbObjectRelationships.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbObjectRelationships_h
#define BbObjectRelationships_h

#import <Foundation/Foundation.h>

@protocol BbObjectParent;

@protocol BbObjectChild <NSObject>

- (NSString *)uniqueID;
- (NSUInteger)indexInParentObject;
- (id<BbObjectParent>)parentObject;

@end

@protocol BbObjectParent <NSObject>

- (NSString *)uniqueID;

- (BOOL)isParentObject:(id<BbObjectChild>)child;
- (void)addChildObject:(id<BbObjectChild>)child;
- (void)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index;
- (void)removeChildObject:(id<BbObjectChild>)child;

- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child;
- (id<BbObjectChild>)childObjectAtIndex:(NSUInteger)index;

@end

#endif /* BbObjectRelationships_h */
