//
//  BbObject+Meta.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbRuntime.h"
#import "BbTextDescription.h"

@implementation BbObject (Meta)

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description
{
    BbObject *object = (BbObject *)[NSInvocation doClassMethod:description.objectClass selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:object selector:@"initWithArguments:" arguments:description.objectArguments];
    object.viewClass = description.viewClass;
    object.viewArguments = description.viewArguments;
    return object;
}

- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description
{
    NSUInteger childCount = self.myChildren.count;
    NSAssert(description.senderParentIndex < childCount, @"ERROR: Sending object index %@",@(description.senderParentIndex));
    BbObject *sendingObject = [self.myChildren objectAtIndex:description.senderParentIndex];
    NSUInteger sendingObjectOutletCount = sendingObject.myOutlets.count;
    NSAssert(description.senderPortIndex<sendingObjectOutletCount, @"ERROR: Sending port index: %@",@(description.senderPortIndex));
    BbOutlet *sender = [sendingObject.myOutlets objectAtIndex:description.senderPortIndex];
    NSAssert(description.receiverParentIndex < childCount, @"ERROR: Receiving Object index: %@",@(description.receiverParentIndex));
    BbObject *receivingObject = [self.myChildren objectAtIndex:description.receiverParentIndex];
    NSUInteger receivingObjectInletCount = receivingObject.myInlets.count;
    NSAssert(description.receiverPortIndex<receivingObjectInletCount, @"ERROR: Receiving port index: %@",@(description.receiverPortIndex));
    BbInlet *receiver = [receivingObject.myInlets objectAtIndex:description.receiverPortIndex];
    BbConnection *connection = [[BbConnection alloc]initWithSender:sender receiver:receiver parent:self];
    return connection;
}

@end


