//
//  BbObject.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"

static void     *BbObjectContextXX      =       &BbObjectContextXX;

@interface BbObject ()


@end

@implementation BbObject

- (instancetype)initWithArguments:(NSString *)arguments
{
    self = [super init];
    if ( self ) {
        _objectArguments = arguments;
        [self commonInit];
        [self setupWithArguments:arguments];
    }
    
    return self;
}

- (void)commonInit
{
    self.uniqueID = [BbHelpers createUniqueIDString];
    self.objectClass = NSStringFromClass([self class]);
    self.myInlets = [NSMutableArray array];
    self.myOutlets = [NSMutableArray array];
    self.myChildren = [NSMutableArray array];
    self.myConnections = [NSMutableArray array];
    self.observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [self setupPorts];
}

- (void)setupPorts
{
    [self setupDefaultPorts];
}

- (void)setupWithArguments:(id)arguments {


}

- (NSString *)myToken
{
    return @"#X";
}

- (NSString *)myViewClass
{
    if ( nil != self.viewClass ) {
        return self.viewClass;
    }
    
    return @"BbBoxView";
}

- (NSString *)textDescription
{
    NSMutableArray *myComponents = [NSMutableArray array];
    [myComponents addObject:[self myToken]];
    [myComponents addObject:[self myViewClass]];
    
    if ( nil != self.viewArguments ) {
        [myComponents addObject:self.viewArguments];
    }
    [myComponents addObject:NSStringFromClass([self class])];
    
    if ( nil != self.objectArguments ) {
        [myComponents addObject:self.objectArguments];
    }
    
    NSString *endOfLine = @";\n";
    NSString *myDescription = [[myComponents componentsJoinedByString:@" "]stringByAppendingString:endOfLine];
    NSMutableString *mutableString = [NSMutableString stringWithString:myDescription];
    if ( self.myChildren ) {
        for (BbObject *aChild in self.myChildren ) {
            NSString *depthString = [aChild.parent depthStringForChildObject:aChild];
            [mutableString appendFormat:@"%@%@",depthString,[aChild textDescription]];

        }
    }
    
    if ( nil != self.myConnections ) {
        for (BbConnection *aConnection in self.myConnections ) {
            NSString *depthString = [aConnection.parent depthStringForChildObject:aConnection];
            [mutableString appendFormat:@"%@%@",depthString,[aConnection textDescription]];
        }
    }
    
    return [NSString stringWithString:mutableString];
    
}

#pragma mark - BbObject Protocol

- (BOOL)addObjectObserver:(id<BbObject>)object
{
    if ( [self.observers containsObject:object] ) {
        return NO;
    }
    [self.observers addObject:object];
    [object startObservingObject:self];
    return YES;
}

- (BOOL)removeObjectObserver:(id<BbObject>)object
{
    if ( ![self.observers containsObject:object] ) {
        return NO;
    }
    
    [self.observers removeObject:object];
    return [object stopObservingObject:(id<BbObject>)self];
}

- (BOOL)removeAllObjectObservers{
    if ( !self.observers.count ) {
        return YES;
    }
    
    NSMutableArray *observers = self.observers.allObjects.mutableCopy;
    for (id<BbObject>anObserver in observers ) {
        [self removeObjectObserver:anObserver];
    }
    
    return YES;
}

- (void)dealloc
{
    
    [self removeAllObjectObservers];
    
    for ( BbConnection *aConnection in _myConnections.mutableCopy ) {
        [self removeChildObject:aConnection];
    }
    
    _myConnections = nil;
    
    for ( BbObject *aChildObject in _myChildren.mutableCopy ) {
        [self removeChildObject:aChildObject];
    }
    
    _myChildren = nil;
    
    for (BbInlet *anInlet in _myInlets.mutableCopy ) {
        [self removeChildObject:anInlet];
    }
    _myInlets = nil;
    
    for (BbOutlet *anOutlet in _myOutlets.mutableCopy ) {
        [self removeChildObject:anOutlet];
    }
    
    _myOutlets = nil;
    
    if ( nil != _view ) {
        [_view removeFromSuperView];
    }
    
    _view = nil;
}

@end
