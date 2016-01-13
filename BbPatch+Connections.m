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
    [connection createPathWithDelegate:self.view];
    [self.view addConnectionPath:[connection path]];
    
}

- (void)didRemoveChildConnection:(BbConnection *)connection
{
    BbPort *sender = connection.sender;
    BbPort *receiver = connection.receiver;
    connection.connected = ![sender disconnectFromPort:receiver];
    [self.view removeConnectionPath:connection];
}


#pragma mark - BbConnectionPathDelegate


@end
