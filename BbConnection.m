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

@property (nonatomic,strong)            NSValue             *senderPosition;
@property (nonatomic,strong)            NSValue             *receiverPosition;

@end

@implementation BbConnection

- (instancetype)initWithSender:(id<BbObjectChild>)sender receiver:(id<BbObjectChild>)receiver parent:(id<BbObjectParent>)parent
{
    self = [super init];
    if ( self ) {
        _sender = sender;
        _receiver = receiver;
        _parent = parent;
        self.uniqueID = [NSString stringWithFormat:@"%@-%@-%@",[_parent uniqueID],[_sender uniqueID],[_receiver uniqueID]];
    }
    
    return self;
}

- (void)createPathWithDelegate:(id<BbConnectionPathDelegate>)delegate
{
    if ( nil != self.path ) {
        [self.path removeFromParentView];
        self.path = nil;
    }
    
    [[self.sender parent]addObjectObserver:self];
    [[self.receiver parent]addObjectObserver:self];
    
    self.path = [BbConnectionPath addConnectionPathWithDelegate:delegate dataSource:self];
}

#pragma mark - BbObject

- (BOOL)startObservingObject:(id<BbObject>)object
{
    NSObject *obj = (NSObject *)object;
    [obj addObserver:self forKeyPath:kObservedKeyPath options:NSKeyValueObservingOptionNew context:BbConnectionPathObservationContextXX];
    return YES;
}

- (BOOL)stopObservingObject:(id<BbObject>)object
{
    NSObject *obj = (NSObject *)object;
    [obj removeObserver:self forKeyPath:kObservedKeyPath context:BbConnectionPathObservationContextXX];
    return YES;
}

#pragma mark - BbConnectionPathDataSource

- (UIView *)getSendingView:(id<BbConnectionPath>)sender
{
    return (UIView *)[self.sender view];
}

- (UIView *)getReceivingView:(id<BbConnectionPath>)sender
{
    return (UIView *)[self.receiver view];
}

- (NSString *)connectionIDForConnectionPath:(id<BbConnectionPath>)connectionPath
{
    return self.uniqueID;
}

- (NSValue *)originPointForConnectionPath:(id<BbConnectionPath>)connectionPath
{
   return [[self.sender view]objectViewPosition];
}

- (NSValue *)terminalPointForConnectionPath:(id<BbConnectionPath>)connectionPath
{
    return [[self.receiver view]objectViewPosition];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == BbConnectionPathObservationContextXX) {
        if ( [object isParentObject:self.sender] ) {
            NSString *string = change[@"new"];
            CGPoint point = CGPointFromString(string);
            self.senderPosition = [NSValue valueWithCGPoint:point];
            [self.path setNeedsRedraw:YES];
        }else if ( [object isParentObject:self.receiver] ){
            NSString *string = change[@"new"];
            CGPoint point = CGPointFromString(string);
            self.receiverPosition = [NSValue valueWithCGPoint:point];
            [self.path setNeedsRedraw:YES];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc
{
    [_sender removeObjectObserver:self];
    [_receiver removeObjectObserver:self];
    _parent = nil;
    [_path removeFromParentView];
    _path = nil;
}

@end
