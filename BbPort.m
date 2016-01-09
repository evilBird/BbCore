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
    self.myConnections = [NSMutableSet set];
    self.inputBlock = [BbPort passThruPortBlock];
    self.outputBlock = [BbPort passThruPortBlock];
    _inputElement = nil;
    _outputElement = nil;
    self.validKeyPathArray = @[kOutputElement, kInputElement];
    self.validKeyPaths = [NSSet setWithArray:self.validKeyPathArray];
    [self addObserver:self forKeyPath:kInputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [self addObserver:self forKeyPath:kOutputElement options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
}

- (id)getValue
{
    return self.outputElement;
}

- (NSArray *)connections
{
    if ( nil == self.myConnections ) {
        return nil;
    }
    
    if ( nil == self.parent ) {
        return nil;
    }
    
    return [NSArray arrayWithArray:self.myConnections.allObjects];
}

+ (BbPortBlock)passThruPortBlock
{
    BbPortBlock block = ^(id value){
        return value;
    };
    
    return block;
}

#pragma mark - BbPortConnectionDelegate

- (id)viewPosition:(id)sender
{
    if ( nil == self.view ) {
        return nil;
    }
    
    return [self.view objectViewPosition:self];
}

- (BOOL)hasConnection:(BbConnection *)connection
{
    if ( nil == connection || nil == self.myConnections ) {
        return NO;
    }
    return [[NSSet setWithArray:self.myConnections.allObjects]containsObject:connection.uniqueID];
}

- (BOOL)makeConnection:(BbConnection *)connection withElement:(BbPortElement)element ofPort:(BbPort *)port
{
    if ( [self hasConnection:connection] || [port hasConnection:connection] ) {
        return NO;
    }
    
    NSString *keyPath = ( element == BbPortElement_Output ) ? ( kOutputElement ) : ( kInputElement );
    [port addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:BbPortObservationContextXX];
    [port.myConnections addObject:connection.uniqueID];
    [self.myConnections addObject:connection.uniqueID];
    
    return YES;
}

- (BOOL)removeConnection:(BbConnection *)connection withElement:(BbPortElement)element ofPort:(BbPort *)port
{
    if ( ![self hasConnection:connection] || ![port hasConnection:connection] ) {
        return NO;
    }
    NSString *keyPath = ( element == BbPortElement_Output ) ? ( kOutputElement ) : ( kInputElement );
    [port removeObserver:self forKeyPath:keyPath context:BbPortObservationContextXX];
    [self.myConnections removeObject:connection.uniqueID];
    [port.myConnections removeObject:connection.uniqueID];
    return NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == BbPortObservationContextXX && [self.validKeyPaths containsObject:keyPath] ) {
        BbPortElement element = [self.validKeyPathArray indexOfObject:keyPath];
        switch (element) {
            case BbPortElement_Output:
            {
                if ( object == self ) {
                    self.outputBlock(change[@"new"]);
                }else{
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
        [_view removeFromSuperView];
    }
    _view = nil;
    [self removeObserver:self forKeyPath:kInputElement context:BbPortObservationContextXX];
    [self removeObserver:self forKeyPath:kOutputElement context:BbPortObservationContextXX];
    _inputBlock = nil;
    _outputBlock = nil;
    _inputElement = nil;
    _outputElement = nil;
}

#pragma mark - BbChildObject

- (NSUInteger)indexInParent
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChild:self];
}

@end


@implementation BbInlet

- (void)commonInit
{
    [super commonInit];
    self.scope = BbPortScope_Input;
}

@end


@implementation BbOutlet

- (void)commonInit
{
    [super commonInit];
    self.scope = BbPortScope_Output;
}
@end
