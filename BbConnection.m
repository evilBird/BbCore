//
//  BbConnection.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbConnection.h"
#import "BbPort.h"
#import "BbObject.h"

@interface BbConnection ()

@end

@implementation BbConnection

- (instancetype)initWithSender:(BbOutlet<BbConnectionDelegate>*)sender receiver:(BbInlet<BbConnectionDelegate>*)receiver
{
    self = [super init];
    if ( self ) {
        _sender = sender;
        _receiver = receiver;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSString *senderID = [self.sender uniqueID];
    NSString *receiverID = [self.receiver uniqueID];
    _uniqueID = [NSString stringWithFormat:@"%@.%@",senderID,receiverID];
}

- (BOOL)connectInParent:(BbObject<BbObjectParent>*)parent
{
    if ( nil == parent || ![self isValid] ) {
        return NO;
    }
    
    self.parent = parent;
    _connected = [self.receiver makeConnection:self withElement:BbPortElement_Output ofPort:self.sender];
    return _connected;
}

- (BOOL)disconnect
{
    if ( _connected == NO ) {
        return _connected;
    }
    
    BOOL success = [self.receiver removeConnection:self withElement:BbPortElement_Output ofPort:self.sender];
    _connected = success;
    _sender = nil;
    _receiver = nil;
    return success;
}

- (NSString *)textDescription
{
    if ( ![self isValid] ) {
        return nil;
    }
    
    NSUInteger senderIndex = [self.sender indexInParent];
    NSUInteger receiverIndex = [self.receiver indexInParent];
    NSUInteger senderParentIndex = [self.parent indexOfChild:self.sender.parent];
    NSUInteger receiverParentIndex = [self.parent indexOfChild:self.receiver.parent];
    NSString *description = [NSString stringWithFormat:@"#X connection %@ %@ %@ %@;\n",@(senderParentIndex),@(senderIndex),@(receiverParentIndex),@(receiverIndex)];
    return description;
}

- (BOOL)senderIsValid
{
    if ( nil == self.sender || nil == self.sender.parent ) {
        return NO;
    }

    if ( [self.sender.parent indexOfChild:self.sender] == BbIndexInParentNotFound ) {
        return NO;
    }
    
    if ( [self.parent indexOfChild:self.sender.parent] == BbIndexInParentNotFound ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)receiverIsValid
{
    if ( nil == self.receiver || nil == self.receiver.parent ) {
        return NO;
    }

    if ( [self.receiver.parent indexOfChild:self.receiver] == BbIndexInParentNotFound ) {
        return NO;
    }
    
    if ( [self.parent indexOfChild:self.receiver.parent] == BbIndexInParentNotFound ) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isValid
{
    return ([self senderIsValid]&&[self receiverIsValid]);
}

- (id)connectionPoints
{
    id position1 = [self.sender viewPosition:self];
    id position2 = [self.receiver viewPosition:self];
    if ( nil != position1 && nil != position2 ) {
        return @[position1,position2];
    }
    return nil;
}

- (void)dealloc
{
    [self disconnect];
    _parent = nil;
}

@end
