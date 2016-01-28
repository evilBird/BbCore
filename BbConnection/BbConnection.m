//
//  BbConnection.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbConnection.h"
#import "BbPort.h"
#import "BbCoreProtocols.h"
#import "BbConnectionPath.h"
#import "BbTextDescription.h"
#import "BbParseText.h"

static NSString  *kObservedKeyPath = @"viewArguments";

static void*     BbConnectionPathObservationContextXX       =       &BbConnectionPathObservationContextXX;

@interface BbConnection ()

@end

@implementation BbConnection

+ (BbConnection *)connectionWithSender:(id<BbEntity>)sender receiver:(id<BbEntity>)receiver
{
    return [[BbConnection alloc]initWithSender:sender receiver:receiver];
}

- (instancetype)initWithSender:(id<BbEntity>)sender receiver:(id<BbEntity>)receiver
{
    self = [super init];
    if ( self ) {
        _sender = sender;
        _receiver = receiver;
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
    self.connected = NO;
}

- (BOOL)connect
{
    if ( self.isConnected ) {
        return NO;
    }
    
    self.connected = [(BbPort *)self.sender connectToPort:(BbPort *)self.receiver];
    return self.isConnected;
}

- (BOOL)disconnect
{
    if ( self.isConnected == NO ) {
        return YES;
    }
    
    self.connected = ![(BbPort *)self.sender disconnectFromPort:(BbPort *)self.receiver];
    [self unloadPath];
    return self.isConnected;
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
    [self disconnect];
    [self unloadPath];
    _sender = nil;
    _receiver = nil;
    _parent = nil;
}

@end

@implementation BbConnection (BbEntityProtocol)

- (BbConnectionDescription *)connectionDescription
{
    NSString *textDescription = [self textDescription];
    NSString *arguments = [BbParseText connectionArgumentsFromString:textDescription];
    BbConnectionDescription *connectionDescription = [BbConnectionDescription connectionDescriptionWithArgs:arguments];
    return connectionDescription;
}

- (void)updatePath
{
    id<BbEntityView> senderView = self.sender.view;
    id<BbEntityView> receiverView = self.receiver.view;
    id<BbEntityView> patchView = self.sender.parent.parent.view;
    self.path.startPoint = [(BbConnectionPath *)self.path centerPointValueForEntityView:senderView inParentView:patchView];
    self.path.endPoint = [(BbConnectionPath *)self.path centerPointValueForEntityView:receiverView inParentView:patchView];
    self.path.needsRedraw = YES;
}

- (BOOL)isChildOfEntity:(id<BbEntity>)entity
{
    if ( nil == entity || nil == self.parent ) {
        return NO;
    }
    
    return ( entity == self.parent );
}

- (id)loadPath
{
    self.path = nil;
    BbConnectionPath *path = [BbConnectionPath new];
    path.valid = ( [self.sender.parent addEntityObserver:self] && [self.receiver.parent addEntityObserver:self] );
    
    if ( !path.isValid ) {
        return nil;
    }
    path.entity = self;
    self.path = path;
    [self updatePath];
    return path;
}

- (void)unloadPath
{
    if ( nil == self.path ) {
        return;
    }
    self.path.valid = !( [self.sender.parent removeEntityObserver:self] && [self.receiver.parent removeEntityObserver:self] );
    self.path.entity = nil;
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
    return YES;
}

@end

