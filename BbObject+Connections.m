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
    [connection connect];
}

- (void)didRemoveChildConnection:(BbConnection *)connection
{
    [connection disconnect];
}

@end
