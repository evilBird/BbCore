//
//  BbConnection.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbObjectParent.h"

@class BbConnection;
@class BbObject;
@class BbPort;
@class BbInlet;
@class BbOutlet;

typedef NS_ENUM(NSUInteger, BbPortElement) {
    BbPortElement_Output,
    BbPortElement_Input
};


@protocol BbConnectionDelegate <NSObject,BbObjectChild>

- (id)viewPosition:(id)sender;
- (BOOL)hasConnection:(BbConnection *)connection;
- (BOOL)makeConnection:(BbConnection *)connection withElement:(BbPortElement)element ofPort:(BbPort *)port;
- (BOOL)removeConnection:(BbConnection *)connection withElement:(BbPortElement)element ofPort:(BbPort *)port;

@end

@interface BbConnection : NSObject

@property (nonatomic,weak)                              BbObject<BbObjectParent>                *parent;
@property (nonatomic,weak)                              BbOutlet<BbConnectionDelegate>          *sender;
@property (nonatomic,weak)                              BbInlet<BbConnectionDelegate>           *receiver;

@property (nonatomic,readonly,getter=isValid)           BOOL                                    valid;
@property (nonatomic,readonly,getter=isConnected)       BOOL                                    connected;
@property (nonatomic,readonly)                          NSString                                *textDescription;
@property (nonatomic,readonly)                          NSString                                *uniqueID;


- (instancetype)initWithSender:(BbOutlet<BbConnectionDelegate>*)sender receiver:(BbInlet<BbConnectionDelegate>*)receiver;
- (BOOL)connectInParent:(BbObject<BbObjectParent>*)parent;
- (BOOL)disconnect;
- (id)connectionPoints;

@end
