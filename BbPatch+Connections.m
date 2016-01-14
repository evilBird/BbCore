//
//  BbPatch+Connections.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPatch.h"

@implementation BbPatch (Connections)

- (void)didAddChildConnection:(BbConnection *)connection
{
    if ( [connection validate] ) {
        BbPort *sender = connection.sender;
        BbPort *receiver = connection.receiver;
        [sender connectToPort:receiver];
        [self.view addConnection:(id<BbConnection>)connection];
    }else{
        [self removeChildObject:connection];
    }
}

- (void)didRemoveChildConnection:(BbConnection *)connection
{
    BbPort *sender = connection.sender;
    BbPort *receiver = connection.receiver;
    [sender disconnectFromPort:receiver];
    [self.view removeConnection:(id<BbConnection>)connection];
    connection = nil;
}

@end
