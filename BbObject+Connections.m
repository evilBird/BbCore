//
//  BbObject+Connections.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbObject.h"

@implementation BbObject (Connections)

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
    connection.connected = [sender disconnectFromPort:receiver];
    
}

@end
