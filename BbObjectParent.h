//
//  BbObjectParent.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#ifndef BbObjectParent_h
#define BbObjectParent_h

#import "BbObjectChild.h"

#define BbIndexInParentNotFound 1e7

@protocol BbObjectParent <NSObject,BbObjectChild>

- (BOOL)isParentObject:(id<BbObjectChild>)child;

- (BOOL)addChildObject:(id<BbObjectChild>)child;

- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index;

- (BOOL)removeChildObject:(id<BbObjectChild>)child;

- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child;

@optional

- (NSString *)depthStringForChildObject:(id<BbObjectChild>)child;

- (void)loadViews;

- (NSString *)descriptionToken;

- (NSString *)textDescription;

@end


#endif /* BbObjectParent_h */
