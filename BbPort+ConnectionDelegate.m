//
//  BbPort+ConnectionDelegate.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPort.h"

@implementation BbPort (BbConnectionDelegate)

- (id)viewPosition:(id)sender
{
    if ( nil == self.view ) {
        return nil;
    }
    
    return [self.view objectViewPosition:self];
}

- (BOOL)hasConnection:(BbConnection *)connection
{
    if ( nil == connection || nil == self.myConnections ) {
        return NO;
    }
    return [[NSSet setWithArray:self.myConnections.allObjects]containsObject:connection.uniqueID];
}

- (BOOL)makeConnection:(BbConnection *)connection withElement:(BbPortElement)element ofPort:(BbPort *)port
{
    if ( [self hasConnection:connection] || [port hasConnection:connection] ) {
        return NO;
    }
    
    NSString *keyPath = ( element == BbPortElement_Output ) ? ( kOutputElement ) : ( kInputElement );
    [port addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [port.myConnections addObject:connection.uniqueID];
    [self.myConnections addObject:connection.uniqueID];
    
    return YES;
}

- (BOOL)removeConnection:(BbConnection *)connection withElement:(BbPortElement)element ofPort:(BbPort *)port
{
    if ( ![self hasConnection:connection] || ![port hasConnection:connection] ) {
        return NO;
    }
    NSString *keyPath = ( element == BbPortElement_Output ) ? ( kOutputElement ) : ( kInputElement );
    [port removeObserver:self forKeyPath:keyPath context:BbPortObservationContextXX];
    [self.myConnections removeObject:connection.uniqueID];
    [port.myConnections removeObject:connection.uniqueID];
    return NO;
}


@end
