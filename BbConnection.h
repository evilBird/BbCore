//
//  BbConnection.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbConnectionDelegate.h"
#import "BbObjectChild.h"
#import "BbObjectParent.h"
#import "BbConnectionPath.h"
#import "BbConnectionPathDataSource.h"

@interface BbConnection : NSObject

@property (nonatomic,weak)                              id <BbObjectParent>                     parent;
@property (nonatomic,weak)                              id <BbObjectChild>                      sender;
@property (nonatomic,weak)                              id <BbObjectChild>                      receiver;
@property (nonatomic,strong)                            id <BbConnectionPath>                   path;

@property (nonatomic,readonly)                          NSString                                *uniqueID;
@property (nonatomic,getter=isConnected)                BOOL                                    connected;

- (instancetype)initWithSender:(id<BbObjectChild>)sender receiver:(id<BbObjectChild>)receiver parent:(id<BbObjectParent>)parent;

@end

@interface BbConnection (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;
- (NSString *)textDescription;

@end

@interface BbConnection (BbConnectionPathDataSource) <BbConnectionPathDataSource>

- (NSValue *)originPointForConnectionPath:(id<BbConnectionPath>)connectionPath;
- (NSValue *)terminalPointForConnectionPath:(id<BbConnectionPath>)connectionPath;

@end