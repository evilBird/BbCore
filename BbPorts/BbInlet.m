//
//  BbInlet.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbInlet.h"
#import "BbRuntime.h"
#import "BbCoreProtocols.h"

@implementation BbInlet

- (void)commonInit
{
    [super commonInit];
    self.scope = BbPortScope_Input;
    self.weakConnections = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
}


@end


@implementation BbInlet (BbEntityProtocol)

+ (NSString *)viewClass
{
    return @"BbInletView";
}

- (NSSet *)childConnections
{
    if ( nil == self.weakConnections ) {
        return [NSSet set];
    }
    
    return [NSSet setWithArray:self.weakConnections.allObjects];
}

- (BOOL)addChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || [self isParentOfEntity:entity] ) {
        return NO;
    }
    
    [self.weakConnections addObject:entity];
    return YES;
}

- (BOOL)removeChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || ![self isParentOfEntity:entity] ) {
        return NO;
    }
    
    [self.weakConnections removeObject:entity];
    return YES;
}

- (BOOL)isParentOfEntity:(id<BbEntity>)entity
{
    if ( nil == entity || nil == self.weakConnections ) {
        return NO;
    }
    
    return [self.weakConnections containsObject:entity];
}

@end