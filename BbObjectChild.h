//
//  BbObjectChild.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbObjectChild_h
#define BbObjectChild_h

#import "BbObjectRelationshipDefs.h"

@protocol BbObjectChild <NSObject>

@property (nonatomic,strong)        NSString                *uniqueID;
@property (nonatomic,weak)          id<BbObjectParent>      parent;

- (NSUInteger)indexInParent;

@optional

- (NSString *)textDescription;

@end

#endif /* BbObjectChild_h */
