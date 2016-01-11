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

@protocol BbObjectParent;

@protocol BbObjectChild <NSObject>

- (NSString *)uniqueID;
- (NSUInteger)indexInParentObject;
- (id<BbObjectParent>)parentObject;

@end

#endif /* BbObjectChild_h */
