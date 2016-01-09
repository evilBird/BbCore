//
//  BbObjectParent.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#ifndef BbObjectParent_h
#define BbObjectParent_h

#import <Foundation/Foundation.h>

@class BbObject;
@class BbPort;
@class BbConnection;
@protocol BbObjectParent;

#define BbIndexInParentNotFound 1e8

@protocol BbObjectChild <NSObject>

@property (nonatomic,weak)                  id <BbObjectParent>                      parent;

- (NSUInteger)indexInParent;

@end

@protocol BbObjectParent <NSObject>

@property (nonatomic,weak)                  BbObject <BbObjectParent>                *parent;
@property (nonatomic,strong)                NSString                                 *uniqueID;

@optional

//- (NSString *)uniqueID:(id<BbObjectChild>)sender;
- (NSUInteger)indexOfChild:(id<BbObjectChild>)sender;

- (BOOL)hasChildPortWithID:(NSString *)uniqueID;
- (BOOL)hasChildObjectWithID:(NSString *)uniqueID;
- (BOOL)hasConnectionWithID:(NSString *)uniqueID;

- (BbObject *)childObjectWithID:(NSString *)uniqueID;
- (BbPort *)childPortWithID:(NSString *)uniqueID;
- (BbConnection *)childConnectionWithID:(NSString *)uniqueID;

- (BOOL)connectionDidInvalidate:(BbConnection *)connection;

@end


@protocol BbObjectView <NSObject>

+ (id<BbObjectView>)createWithArguments:(NSString *)arguments;
- (void)removeFromSuperView;
- (void)addSubview:(id<BbObjectView>)view;
- (void)addConnectionWithPoints:(id)connection;
- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;
- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;
- (void)removeConnection:(id)connection;
- (id)objectViewPosition:(id)sender;

@end

#endif /* BbObjectParent_h */
