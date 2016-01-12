//
//  BbObjectParent.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#ifndef BbObjectParent_h
#define BbObjectParent_h

#import "BbObjectRelationshipDefs.h"

@protocol BbObjectParent <NSObject,BbObjectChild>

@property (nonatomic,strong)        NSString            *uniqueID;

- (BOOL)isParentObject:(id<BbObjectChild>)child;
- (BOOL)addChildObject:(id<BbObjectChild>)child;
- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index;
- (BOOL)removeChildObject:(id<BbObjectChild>)child;
- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child;

@end

#endif /* BbObjectParent_h */
