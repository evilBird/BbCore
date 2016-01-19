//
//  BbPort.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPort.h"
#import "BbHelpers.h"
#import "BbObject.h"



static void *BbPortObservationContextXX     =       &BbPortObservationContextXX;

@interface BbPort ()

@property (nonatomic,strong)                NSArray         *validKeyPathArray;
@property (nonatomic,strong)                NSSet           *validKeyPaths;

@end

@implementation BbPort

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.uniqueID = [BbHelpers createUniqueIDString];
    self.inputBlock = [BbPort passThroughInputBlock];
    
    self.outputBlock = nil;
    _inputElement = nil;
    _outputElement = nil;
    self.observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.validKeyPathArray = @[kOutputElement, kInputElement];
    self.validKeyPaths = [NSSet setWithArray:self.validKeyPathArray];
    [self addObserver:self forKeyPath:kInputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [self addObserver:self forKeyPath:kOutputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
}

- (BOOL)connectToPort:(BbPort *)port
{
    [self addObjectObserver:port];
    return YES;
}

- (BOOL)disconnectFromPort:(BbPort *)port
{
    [self removeObjectObserver:port];
    return YES;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == BbPortObservationContextXX && [self.validKeyPaths containsObject:keyPath] ) {
        BbPortElement element = [self.validKeyPathArray indexOfObject:keyPath];
        switch (element) {
            case BbPortElement_Output:
            {
                if ( object == self && nil != self.outputBlock ) {
                    self.outputBlock(_outputElement);
                }else if ( object != self ) {
                    self.inputElement = change[@"new"];
                }
                break;
            }
            default:
            {
                self.outputElement = self.inputBlock(change[@"new"]);
            }
                break;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    if ( nil != _view ) {
        [_view removeFromSuperview];
    }
    _view = nil;
    
    [self removeObserver:self forKeyPath:kInputElement context:BbPortObservationContextXX];
    [self removeObserver:self forKeyPath:kOutputElement context:BbPortObservationContextXX];
    
    [self removeAllObjectObservers];
    
    _observedPorts = nil;
    _inputBlock = nil;
    _outputBlock = nil;
    _inputElement = nil;
    _outputElement = nil;
}

#pragma mark - <BbObject>

- (BOOL)startObservingObject:(id<BbObject>)object
{
    NSObject *obj = (NSObject *)object;
    [obj addObserver:self forKeyPath:@"outputElement" options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    return YES;
}

- (BOOL)stopObservingObject:(id<BbObject>)object
{
    NSObject *obj = (NSObject *)object;
    [obj removeObserver:self forKeyPath:@"outputElement" context:BbPortObservationContextXX];
    return YES;
}

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

- (BOOL)removeAllObjectObservers
{
    if ( !self.observers.count ) {
        return YES;
    }
    
    NSMutableArray *observers = self.observers.allObjects.mutableCopy;
    for (id<BbObject>anObserver in observers ) {
        [self removeObjectObserver:anObserver];
    }
    
    return YES;
}

@end

