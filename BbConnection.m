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

- (instancetype)initWithSender:(id<BbObjectChild>)sender receiver:(id<BbObjectChild>)receiver parent:(id<BbObjectParent>)parent
{
    self = [super init];
    if ( self ) {
        _sender = sender;
        _receiver = receiver;
        _parent = parent;
        _uniqueID = [NSString stringWithFormat:@"%@-%@-%@",[_parent uniqueID],[_sender uniqueID],[_receiver uniqueID]];
    }
    
    return self;
}

- (BOOL)connect
{
    [self.parent addChildObject:self];
    return YES;
}

- (BOOL)disconnect
{
    [self.parent removeChildObject:self];
    return YES;
}

- (void)dealloc
{
    if ( self.isConnected ) {
        [self disconnect];
    }

    _parent = nil;
}

@end
