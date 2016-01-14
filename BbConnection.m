//
//  BbConnection.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbConnection.h"
#import "BbPort.h"
#import "BbObject.h"
#import "BbHelpers.h"

static NSString  *kObservedKeyPath = @"viewArguments";

static void*     BbConnectionPathObservationContextXX       =       &BbConnectionPathObservationContextXX;

@interface BbConnection ()

@property      (nonatomic,getter=isObservingSender)                  BOOL           observingSender;
@property      (nonatomic,getter=isObservingReceiver)                BOOL           observingReceiver;

@end

@implementation BbConnection

- (instancetype)initWithSender:(id<BbObjectChild>)sender receiver:(id<BbObjectChild>)receiver parent:(id<BbObjectParent>)parent
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
    self.uniqueID = [NSString stringWithFormat:@"%@.%@.%@",[_parent uniqueID],[_sender uniqueID],[_receiver uniqueID]];
    [[self.sender parent]addObjectObserver:self];
    [[self.receiver parent]addObjectObserver:self];
}

#pragma mark - Accessors

- (void)setValid:(BOOL)valid
{
    BOOL wasValid = self.isValid;
    _valid = valid;
    if ( _valid != wasValid ) {
        [self validityDidChange:valid];
    }
}

- (void)validityDidChange:(BOOL)validity
{
    if ( !validity ) {
        [self.parent removeChildObject:self];
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

- (UIView *)inletView
{
    return (UIView *)[self.receiver view];
}

- (BOOL)validate
{
    if ( nil != self.sender && nil != self.receiver && nil != self.parent ) {
        return YES;
    }
    
    return NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == BbConnectionPathObservationContextXX) {
        if ( [object isParentObject:self.sender] || [object isParentObject:self.receiver] ) {
            self.needsRedraw = YES;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - BbObject Protcol

- (BOOL)startObservingObject:(id<BbObject>)object
{
    NSObject *obj = (NSObject *)object;
    [obj addObserver:self forKeyPath:kObservedKeyPath options:NSKeyValueObservingOptionNew context:BbConnectionPathObservationContextXX];
    id <BbObjectParent> parent = (id<BbObjectParent>)object;
    
    if ( [parent isParentObject:self.sender] ) {
        self.observingSender = YES;
        self.valid = [self validate];
    }else if ( [parent isParentObject:self.receiver] ){
        self.observingReceiver = YES;
        self.valid = [self validate];
    }
    
    return YES;
}

- (BOOL)stopObservingObject:(id<BbObject>)object
{
    NSObject *obj = (NSObject *)object;
    [obj removeObserver:self forKeyPath:kObservedKeyPath context:BbConnectionPathObservationContextXX];
    id <BbObjectParent> parent = (id<BbObjectParent>)object;
    if ( [parent isParentObject:self.sender] ) {
        self.observingSender = NO;
        self.valid = [self validate];
    }else if ( [parent isParentObject:self.receiver] ){
        self.observingReceiver = NO;
        self.valid = [self validate];
    }
    
    return YES;
}

- (void)dealloc
{
    [_sender removeObjectObserver:self];
    _sender = nil;
    [_receiver removeObjectObserver:self];
    _receiver = nil;
    _parent = nil;
}

@end
