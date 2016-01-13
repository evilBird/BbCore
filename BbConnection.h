//
//  BbConnection.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbBridge.h"

@interface BbConnection : NSObject <BbConnectionPathDataSource,BbObject>

@property (nonatomic,weak)                              id <BbObjectParent>                     parent;
@property (nonatomic,weak)                              id <BbObjectChild>                      sender;
@property (nonatomic,weak)                              id <BbObjectChild>                      receiver;
@property (nonatomic,strong)                            id <BbConnectionPath>                   path;
@property (nonatomic,getter=isConnected)                BOOL                                    connected;

@property (nonatomic,strong)                            NSString                                *uniqueID;
- (instancetype)initWithSender:(id<BbObjectChild>)sender receiver:(id<BbObjectChild>)receiver parent:(id<BbObjectParent>)parent;

- (void)createPathWithDelegate:(id<BbConnectionPathDelegate>)delegate;

#pragma mark - BbObject

- (BOOL)startObservingObject:(id<BbObject>)object;
- (BOOL)stopObservingObject:(id<BbObject>)object;

#pragma mark - BbConnectionPathDataSource

- (NSString *)connectionIDForConnectionPath:(id<BbConnectionPath>)connectionPath;
- (NSValue *)originPointForConnectionPath:(id<BbConnectionPath>)connectionPath;
- (NSValue *)terminalPointForConnectionPath:(id<BbConnectionPath>)connectionPath;

@end

@interface BbConnection (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;
- (NSString *)textDescription;

@end