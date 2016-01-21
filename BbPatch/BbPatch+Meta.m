//
//  BbPatch+Meta.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPatch.h"
#import "BbTextDescription.h"
#import "BbRuntime.h"

@implementation BbPatch (Meta)

+ (BbPatch *)objectWithDescription:(BbPatchDescription *)description
{
    BbPatch *patch = (BbPatch *)[NSInvocation doClassMethod:description.objectClass selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:patch selector:@"initWithArguments:" arguments:description.objectArguments];
    patch.viewClass = description.viewClass;
    patch.viewArguments = description.viewArguments;
    patch.mySelectors = description.selectorDescriptions;
    
    if ( nil != description.childObjectDescriptions ) {
        for (id aDescription in description.childObjectDescriptions ) {
            NSString *className = [(BbObjectDescription *)aDescription objectClass];
            id<BbObjectChild> child = [NSClassFromString(className) objectWithDescription:aDescription];
            [patch addChildObject:child];
        }
    }
    
    if ( nil != description.childConnectionDescriptions ) {
        for (BbConnectionDescription *aDescription in description.childConnectionDescriptions ) {
            BbConnection *connection = [patch connectionWithDescription:aDescription];
            [patch addChildObject:connection];
        }
    }
    
    return patch;
}

- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description
{
    NSUInteger childCount = self.childObjects.count;
    NSAssert(description.senderParentIndex < childCount, @"ERROR: Sending object index %@",@(description.senderParentIndex));
    BbObject *sendingObject = [self.childObjects objectAtIndex:description.senderParentIndex];
    NSUInteger sendingObjectOutletCount = sendingObject.outlets.count;
    NSAssert(description.senderPortIndex<sendingObjectOutletCount, @"ERROR: Sending port index: %@",@(description.senderPortIndex));
    BbOutlet *sender = [sendingObject.outlets objectAtIndex:description.senderPortIndex];
    NSAssert(description.receiverParentIndex < childCount, @"ERROR: Receiving Object index: %@",@(description.receiverParentIndex));
    BbObject *receivingObject = [self.childObjects objectAtIndex:description.receiverParentIndex];
    NSUInteger receivingObjectInletCount = receivingObject.inlets.count;
    NSAssert(description.receiverPortIndex<receivingObjectInletCount, @"ERROR: Receiving port index: %@",@(description.receiverPortIndex));
    BbInlet *receiver = [receivingObject.inlets objectAtIndex:description.receiverPortIndex];
    BbConnection *connection = [[BbConnection alloc]initWithSender:sender receiver:receiver];
    return connection;
}

@end