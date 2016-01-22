//
//  BbOutlet.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbOutlet.h"
#import "BbConnection.h"
@implementation BbOutlet

- (void)commonInit
{
    [super commonInit];
    self.strongConnections = [NSMutableArray array];
    self.scope = BbPortScope_Output;
}


@end

@implementation BbOutlet (BbEntityProtocol)

+ (NSString *)viewClass
{
    return @"BbOutletView";
}

- (NSSet *)childConnections
{
    if ( nil == self.strongConnections || !self.strongConnections.count ) {
        return [NSSet set];
    }
    
    return [NSSet setWithArray:self.strongConnections];
}

- (BOOL)isParentOfEntity:(id<BbEntity>)entity
{
    if ( nil == entity ) {
        return NO;
    }
    
    if ( nil == self.strongConnections || !self.strongConnections.count ) {
        return NO;
    }
    
    return [self.strongConnections containsObject:entity];
}

- (BOOL)addChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || [self isParentOfEntity:entity] ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbConnection class]] ) {
        if ( [(BbConnection *)entity connect] ) {
            [self.strongConnections addObject:entity];
            entity.parent = self;
            [[(BbConnection *)entity receiver] addChildEntity:entity];
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)removeChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || ![self isParentOfEntity:entity]) {
        return NO;
    }
    if ( [entity isKindOfClass:[BbConnection class]] ) {
        if ( [(BbConnection *)entity disconnect] ) {
            [self.strongConnections removeObject:entity];
            entity.parent = nil;
            [[(BbConnection *)entity receiver] removeChildEntity:entity];
            return YES;
        }
    }
    return NO;
}

@end