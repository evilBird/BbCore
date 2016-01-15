//
//  BbPatch.m
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatch.h"

@implementation BbPatch

- (void)commonInit
{
    [super commonInit];
    self.childObjects = [NSMutableArray array];
    self.connections = [NSMutableArray array];
}

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments
{
    self.viewClass = @"BbPatchView";
}

- (void)dealloc
{
    for ( BbConnection *aConnection in _connections.mutableCopy ) {
        [self removeChildObject:aConnection];
    }
    
    _connections = nil;
    
    for ( BbObject *aChildObject in _childObjects.mutableCopy ) {
        [self removeChildObject:aChildObject];
    }
    
    _childObjects = nil;
}

@end

