//
//  BbPort.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPort.h"
#import "BbRuntime.h"

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
    self.uniqueID = [NSString uniqueIDString];
    self.inputBlock = [BbPort passThroughInputBlock];
    self.outputBlock = nil;
    _inputElement = nil;
    _outputElement = nil;
    self.entityObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.validKeyPathArray = @[kOutputElement, kInputElement];
    self.validKeyPaths = [NSSet setWithArray:self.validKeyPathArray];
    [self addObserver:self forKeyPath:kInputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [self addObserver:self forKeyPath:kOutputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
}

- (BOOL)connectToPort:(BbPort *)port
{
    return [self addEntityObserver:port];
}

- (BOOL)disconnectFromPort:(BbPort *)port
{
    return [self removeEntityObserver:port];
}


- (NSUInteger)hash
{
    return [_uniqueID hash];
}

- (BOOL)isEqual:(id)object
{
    return ([self hash] == [object hash]);
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
    [self removeAllEntityObservers];
    [self removeObserver:self forKeyPath:kInputElement context:BbPortObservationContextXX];
    [self removeObserver:self forKeyPath:kOutputElement context:BbPortObservationContextXX];
    
    _entityObservers = nil;
    _inputBlock = nil;
    _outputBlock = nil;
    _inputElement = nil;
    _outputElement = nil;
}

@end

@implementation BbPort (BbEntityProtocol)

+ (NSString *)viewClass
{
    return nil;
}

- (id<BbEntityView>)loadView
{
    NSString *viewClass = [[self class] viewClass];
    if ( nil == viewClass ) {
        return nil;
    }
    id <BbEntityView> myView = [NSInvocation doClassMethod:viewClass selector:@"new" arguments:nil];
    self.view = myView;
    self.view.entity = self;
    return myView;
}

- (void)unloadView
{
    if ( nil == self.view ) {
        return;
    }
    id<BbObjectView> parentView = (id<BbObjectView>)self.parent.view;
    [parentView removeChildEntityView:self.view];
    
    self.view.entity = nil;
    self.view = nil;
}

- (BOOL)addEntityObserver:(id<BbEntity>)entity
{
    if ( [self.entityObservers containsObject:entity] ) {
        return NO;
    }
    
    if ( [entity startObservingEntity:self] ) {
        [self.entityObservers addObject:entity];
        return YES;
    }
    
    return NO;
}

- (BOOL)removeEntityObserver:(id<BbEntity>)entity
{
    if ( [self.entityObservers containsObject:entity] == NO ){
        return NO;
    }
    
    if ( [entity stopObservingEntity:self] ) {
        [self.entityObservers removeObject:entity];
        return YES;
    }
    return NO;
}

- (BOOL)startObservingEntity:(id<BbEntity>)entity
{
    [(NSObject *)entity addObserver:self forKeyPath:@"outputElement" options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    return YES;
}

- (BOOL)stopObservingEntity:(id<BbEntity>)entity
{
    [(NSObject *)entity removeObserver:self forKeyPath:@"outputElement" context:BbPortObservationContextXX];
    return YES;
}

- (BOOL)removeAllEntityObservers
{
    NSArray *entityObservers = self.entityObservers.allObjects;
    for (id <BbEntity> anObserver in entityObservers ) {
        [self removeEntityObserver:anObserver];
    }
    
    return YES;
}

- (BOOL)isChildOfEntity:(id<BbEntity>)entity
{
    if ( nil == self.parent ) {
        return NO;
    }
    
    return ( self.parent == entity );
}

- (NSUInteger)indexInParentEntity
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildEntity:self];
}

@end


