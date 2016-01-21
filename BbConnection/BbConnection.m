//
//  BbConnection.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbConnection.h"

static NSString  *kObservedKeyPath = @"viewArguments";

static void*     BbConnectionPathObservationContextXX       =       &BbConnectionPathObservationContextXX;

@interface BbConnection ()

@property (nonatomic,strong)            UIBezierPath            *myPath;

@end

@implementation BbConnection

+ (BbConnection *)connectionWithSender:(id<BbEntity>)sender receiver:(id<BbEntity>)receiver parent:(id<BbPatch>)parent
{
    return [[BbConnection alloc]initWithSender:sender receiver:receiver parent:parent];
}

- (instancetype)initWithSender:(id<BbEntity>)sender receiver:(id<BbEntity>)receiver parent:(id<BbPatch>)parent
{
    self = [super init];
    if ( self ) {
        _sender = sender;
        _receiver = receiver;
        _parent = parent;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.uniqueID = [NSString uniqueIDString];
    self.senderID = [self.sender uniqueID];
    self.receiverID = [self.receiver uniqueID];
    self.entityObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    if ( [self.sender.parent addEntityObserver:self] && [self.receiver.parent addEntityObserver:self] ) {
        self.valid = YES;
    }
}

#pragma mark - BbConnection Protocol

- (UIView *)parentView
{
    return (UIView *)[self.parent view];
}

- (UIView *)outletView
{
    return (UIView *)[self.sender view];
}

- (UIView *)outletParentView
{
    return (UIView *)[self.sender.parent view];
}

- (UIView *)inletView
{
    return (UIView *)[self.receiver view];
}

- (UIView *)inletParentView
{
    return (UIView *)[self.receiver.parent view];
}

- (void)updatePath
{
    UIView *parentView = [self parentView];
    UIView *senderView = [self outletView];
    UIView *senderParentView = [self outletParentView];
    CGPoint startPoint = [parentView convertPoint:senderView.center fromView:senderParentView];
    
    UIView *receiverView = [self inletView];
    UIView *receiverParentView = [self inletParentView];
    CGPoint endPoint = [parentView convertPoint:receiverView.center fromView:receiverParentView];
    
    [self.myPath removeAllPoints];
    [self.myPath moveToPoint:startPoint];
    [self.myPath addLineToPoint:endPoint];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == BbConnectionPathObservationContextXX) {
        if ( [object isParentOfEntity:self.sender] || [object isParentOfEntity:self.receiver] ) {
            [self updatePath];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [_sender.parent removeEntityObserver:self];
    _sender = nil;
    [_receiver.parent removeEntityObserver:self];
    _receiver = nil;
    _parent = nil;
}

@end

@implementation BbConnection (BbEntityProtocol)

- (id)loadPath
{
    self.myPath = [UIBezierPath bezierPath];
    self.path = self.myPath;
    [self updatePath];
    return self.path;
}

- (void)unloadPath
{
    if ( nil == self.myPath && nil == self.path ) {
        return;
    }
    [self.myPath removeAllPoints];
    self.myPath = nil;
    self.path = nil;
}

- (NSUInteger)indexInParentEntity
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildEntity:self];
}

- (NSString *)textDescriptionToken
{
    return @"#X";
}

- (NSString *)textDescription
{
    NSUInteger senderIndex = [self.sender indexInParentEntity];
    NSUInteger receiverIndex = [self.receiver indexInParentEntity];
    NSUInteger senderParentIndex = [self.sender.parent indexInParentEntity];
    NSUInteger receiverParentIndex = [self.receiver.parent indexInParentEntity];
    NSString *className = NSStringFromClass([self class]);
    NSString *token = [self textDescriptionToken];
    NSString *description = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@;\n",token,className,@(senderParentIndex),@(senderIndex),@(receiverParentIndex),@(receiverIndex)];
    return description;
}

- (BOOL)addEntityObserver:(id<BbEntity>)entity
{
    if ( nil == entity || [self.entityObservers containsObject:entity] ) {
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
    if ( nil == entity || [self.entityObservers containsObject:entity] == NO ) {
        return NO;
    }
    
    if ( [entity stopObservingEntity:self] ) {
        [self.entityObservers removeObject:entity];
        return YES;
    }
    
    return NO;
}

- (BOOL)removeAllEntityObservers
{
    for ( id <BbEntity> entity in self.entityObservers.allObjects ) {
        [self removeEntityObserver:entity];
    }
    return YES;
}

- (BOOL)startObservingEntity:(id<BbEntity>)entity
{
    [(NSObject *)entity addObserver:self forKeyPath:kObservedKeyPath options:NSKeyValueObservingOptionNew context:BbConnectionPathObservationContextXX];
    return YES;
}

- (BOOL)stopObservingEntity:(id<BbEntity>)entity
{
    [(NSObject *)entity removeObserver:self forKeyPath:kObservedKeyPath context:BbConnectionPathObservationContextXX];
    self.valid = NO;
    return YES;
}

@end

