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
    BbPort *sender = connection.sender;
    BbPort *receiver = connection.receiver;
    connection.connected = [sender connectToPort:receiver];
}

- (void)didRemoveChildConnection:(BbConnection *)connection
{
    BbPort *sender = connection.sender;
    BbPort *receiver = connection.receiver;
    connection.connected = ![sender disconnectFromPort:receiver];
}

@end
