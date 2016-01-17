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
    self.inletMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    self.outputMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
}

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments {
    
    NSArray *objectArgs = [arguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.name = objectArgs.firstObject;
}

- (void)addObjectPortForPatchPort:(id<BbObjectChild>)patchPort
{
    if ( [patchPort isKindOfClass:[BbPatchInlet class]] ) {
        
        __block BbPatchInlet *patchInlet = (BbPatchInlet *)patchPort;
        BbInlet *inlet = [[BbInlet alloc]init];
        inlet.hotInlet = YES;
        [self addChildObject:inlet];
        [self.inletMapTable setObject:inlet forKey:patchPort];
        [inlet setOutputBlock:^(id value){
            [patchInlet.inlets[0] setInputElement:value];
        }];
        
    }else if ( [patchPort isKindOfClass:[BbPatchOutlet class]] ){
        
        BbPatchOutlet *patchOutlet = (BbPatchOutlet *)patchPort;
        __block BbOutlet *outlet = [[BbOutlet alloc]init];
        [self addChildObject:outlet];
        [self.outputMapTable setObject:outlet forKey:patchPort];
        [patchOutlet.outlets[0] setOutputBlock:^(id value){
            outlet.inputElement = value;
        }];
    }
}

- (void)insertObjectPortForPatchPort:(id<BbObjectChild>)patchPort atIndex:(NSUInteger)index
{
    if ( [patchPort isKindOfClass:[BbPatchInlet class]] ) {
        
        __block BbPatchInlet *patchInlet = (BbPatchInlet *)patchPort;
        BbInlet *inlet = [[BbInlet alloc]init];
        inlet.hotInlet = YES;
        [self insertChildObject:inlet atIndex:index];
        [self.inletMapTable setObject:inlet forKey:patchPort];
        [inlet setOutputBlock:^(id value){
            [patchInlet.inlets[0] setInputElement:value];
        }];
        
    }else if ( [patchPort isKindOfClass:[BbPatchOutlet class]] ){
        
        BbPatchOutlet *patchOutlet = (BbPatchOutlet *)patchPort;
        __block BbOutlet *outlet = [[BbOutlet alloc]init];
        [self insertChildObject:outlet atIndex:index];
        [self.outputMapTable setObject:outlet forKey:patchPort];
        [patchOutlet.outlets[0] setOutputBlock:^(id value){
            outlet.inputElement = value;
        }];
    }
}

- (void)removeObjectPortForPatchPort:(id<BbObjectChild>)patchPort
{
    if ( [patchPort isKindOfClass:[BbPatchInlet class]] ) {
        
        BbInlet *inlet = [self.inletMapTable objectForKey:patchPort];
        [self removeChildObject:inlet];
        
        
    }else if ( [patchPort isKindOfClass:[BbPatchOutlet class]] ){
        
        BbOutlet *outlet = [self.outputMapTable objectForKey:patchPort];
        [self removeChildObject:outlet];
    }
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

