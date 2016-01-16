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

- (void)setupWithArguments:(id)arguments {
    
    NSArray *objectArgs = [arguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.name = objectArgs.firstObject;
}

+ (NSString *)symbolAlias
{
    return @"Patch";
}

+ (NSString *)viewClass
{
    return @"BbPatchView";
}

- (void)dealloc
{
    [self removeAllObjectObservers];
    
    for (BbInlet *anInlet in self.inlets.mutableCopy ) {
        [self removeChildObject:anInlet];
    }
    self.inlets = nil;
    
    for (BbOutlet *anOutlet in self.outlets.mutableCopy ) {
        [self removeChildObject:anOutlet];
    }
    
    self.outlets = nil;
    
    if ( nil != self.view ) {
        [(UIView *)self.view removeFromSuperview];
    }
    
    self.view = nil;
    
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

