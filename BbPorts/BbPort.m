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
    self.observedPorts = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.validKeyPathArray = @[kOutputElement, kInputElement];
    self.validKeyPaths = [NSSet setWithArray:self.validKeyPathArray];
    [self addObserver:self forKeyPath:kInputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [self addObserver:self forKeyPath:kOutputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
}

- (BOOL)connectToPort:(BbPort *)port
{
    if ( [port.observedPorts containsObject:self] ) {
        return NO;
    }
    
    [self addObserver:port forKeyPath:kOutputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [port.observedPorts addObject:self];
    return YES;
}

- (BOOL)disconnectFromPort:(BbPort *)port
{
    if ( ![port.observedPorts containsObject:self] ) {
        return NO;
    }
    
    [self removeObserver:port forKeyPath:kOutputElement context:BbPortObservationContextXX];
    [port.observedPorts removeObject:self];
    return YES;
}


- (BOOL)connectToElement:(BbPortElement)element ofPort:(BbPort *)portToObserve
{
    if ( [self.observedPorts containsObject:portToObserve] ) {
        return NO;
    }
    
    NSString *keyPath = ( element == BbPortElement_Output ) ? ( kOutputElement ) : ( kInputElement );
    [portToObserve addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [self.observedPorts addObject:portToObserve];
    return YES;
}

- (BOOL)disconnectFromElement:(BbPortElement)element ofPort:(BbPort *)portToObserve
{
    if ( ![self.observedPorts containsObject:portToObserve] ) {
        return NO;
    }
    NSString *keyPath = ( element == BbPortElement_Output ) ? ( kOutputElement ) : ( kInputElement );
    [portToObserve removeObserver:self forKeyPath:keyPath context:BbPortObservationContextXX];
    [self.observedPorts removeObject:portToObserve];
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
    if ( _observedPorts.allObjects.count ) {
        NSMutableArray *observedPorts = _observedPorts.allObjects.mutableCopy;
        
        for (BbPort *anObservedPort in observedPorts ) {
            [anObservedPort disconnectFromPort:self];
        }
    }
    
    _observedPorts = nil;
    _inputBlock = nil;
    _outputBlock = nil;
    _inputElement = nil;
    _outputElement = nil;
}


@end

