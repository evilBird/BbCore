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
    return [BbPatch objectWithDescription:description dataSource:nil];
}

+ (BbPatch *)objectWithDescription:(BbPatchDescription *)description dataSource:(id<BbObjectDataSource>)dataSource
{
    BbPatch *patch = (BbPatch *)[NSInvocation doClassMethod:description.objectClass selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:patch selector:@"initWithArguments:" arguments:nil];
    patch.dataSource = dataSource;
    patch.viewArguments = description.viewArguments;
    patch.selectors = description.selectorDescriptions;
    
    if ( nil != description.childObjectDescriptions ) {
        for (id aDescription in description.childObjectDescriptions ) {
            NSString *className = [(BbObjectDescription *)aDescription objectClass];
            id<BbObject> child = [NSClassFromString(className) objectWithDescription:aDescription dataSource:patch.dataSource];
            [patch addChildEntity:child];
        }
    }
    
    if ( nil != description.childConnectionDescriptions ) {
        for (BbConnectionDescription *aDescription in description.childConnectionDescriptions ) {
            BbConnection *connection = [patch connectionWithDescription:aDescription];
            BOOL success = [connection.sender addChildEntity:connection];
            NSAssert(success, @"ERROR LOADING CONNECTION: %@",aDescription);
        }
    }
    
    [patch doSelectors];
    return patch;
}

+ (BbConnection *)connectionWithDecription:(BbConnectionDescription *)description amongstCopiedObjects:(NSArray *)objects
{
    NSUInteger objectCount = objects.count;
    NSAssert(description.senderParentIndex < objectCount, @"ERROR: INVALID SENDING OBJECT");
    BbObject *sendingObject = objects[description.senderParentIndex];
    NSUInteger sendingObjectOutletCount = sendingObject.outlets.count;
    NSAssert(description.senderPortIndex<sendingObjectOutletCount, @"ERROR: INVALID SENDING PORT");
    BbOutlet *sender = sendingObject.outlets[description.senderPortIndex];
    NSAssert(description.receiverParentIndex < objectCount, @"ERROR: INVALID RECEIVING OBJECT");
    BbObject *receivingObject = objects[description.receiverParentIndex];
    NSUInteger receivingObjectInletCount = receivingObject.inlets.count;
    NSAssert(description.receiverPortIndex < receivingObjectInletCount, @"ERROR: INVALID RECEIVING PORT");
    BbInlet *receiver = receivingObject.inlets[description.receiverPortIndex];
    BbConnection *connection = [BbConnection connectionWithSender:sender receiver:receiver];
    return connection;
}

- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description
{
    NSUInteger childCount = self.objects.count;
    NSAssert(description.senderParentIndex < childCount, @"ERROR: Sending object index: %@",@(description.senderParentIndex));
    BbObject *sendingObject = [self.objects objectAtIndex:description.senderParentIndex];
    NSUInteger sendingObjectOutletCount = sendingObject.outlets.count;
    NSAssert(description.senderPortIndex<sendingObjectOutletCount, @"ERROR: Sending port index: %@",@(description.senderPortIndex));
    BbOutlet *sender = [sendingObject.outlets objectAtIndex:description.senderPortIndex];
    NSAssert(description.receiverParentIndex < childCount, @"ERROR: Receiving Object index: %@",@(description.receiverParentIndex));
    BbObject *receivingObject = [self.objects objectAtIndex:description.receiverParentIndex];
    NSUInteger receivingObjectInletCount = receivingObject.inlets.count;
    NSAssert(description.receiverPortIndex<receivingObjectInletCount, @"ERROR: Receiving port index: %@",@(description.receiverPortIndex));
    BbInlet *receiver = [receivingObject.inlets objectAtIndex:description.receiverPortIndex];
    BbConnection *connection = [BbConnection connectionWithSender:sender receiver:receiver];
    return connection;
}

@end