//
//  BbConnection.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BbCoreProtocols.h>

@interface BbConnection : NSObject

@property (nonatomic,weak)                              id <BbEntity>                           parent;
@property (nonatomic,weak)                              id <BbEntity>                           sender;
@property (nonatomic,weak)                              id <BbEntity>                           receiver;

@property (nonatomic,strong)                            NSString                                *uniqueID;
@property (nonatomic,strong)                            NSString                                *senderID;
@property (nonatomic,strong)                            NSString                                *receiverID;

@property (nonatomic,strong)                            id <BbConnectionPath>                   path;
@property (nonatomic,getter=isConnected)                BOOL                                    connected;

@property (nonatomic,strong)                            NSHashTable                             *entityObservers;

- (instancetype)initWithSender:(id<BbEntity>)sender
                      receiver:(id<BbEntity>)receiver;

+ (BbConnection *)connectionWithSender:(id<BbEntity>)sender receiver:(id<BbEntity>)receiver;

- (BOOL)connect;
- (BOOL)disconnect;

@end

@interface BbConnection (BbEntityProtocol) <BbConnection, BbEntity>

- (BOOL)addEntityObserver:(id<BbEntity>)entity;

- (BOOL)removeEntityObserver:(id<BbEntity>)entity;

- (BOOL)startObservingEntity:(id<BbEntity>)entity;

- (BOOL)stopObservingEntity:(id<BbEntity>)entity;

- (BOOL)removeAllEntityObservers;

- (BOOL)isChildOfEntity:(id<BbEntity>)entity;

- (NSUInteger)indexInParentEntity;

- (NSString *)textDescription;

- (NSString *)textDescriptionToken;

- (void)updatePath;

@end

