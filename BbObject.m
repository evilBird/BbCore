//
//  BbObject.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbHelpers.h"

static void     *BbObjectContextXX      =       &BbObjectContextXX;

@interface BbObject ()

@property (nonatomic,strong)                NSMutableArray                          *myInlets;
@property (nonatomic,strong)                NSMutableArray                          *myOutlets;
@property (nonatomic,strong)                NSMutableArray                          *myChildren;
@property (nonatomic,strong)                NSMutableArray                          *myConnections;

@property (nonatomic,strong)                NSMutableSet                            *childObjectIDs;
@property (nonatomic,strong)                NSMutableSet                            *childPortIDs;

@end

@implementation BbObject

- (instancetype)initWithArguments:(NSString *)arguments
{
    self = [super init];
    if ( self ) {
        _arguments = arguments;
        [self commonInit];
        [self setupWithArguments:[BbHelpers string2Array:arguments]];
    }
    
    return self;
}

- (void)commonInit
{
    self.uniqueID = [BbHelpers createUniqueIDString];
    self.titleText = @"BbObject";
    self.myInlets = [NSMutableArray array];
    self.myOutlets = [NSMutableArray array];
    self.myChildren = [NSMutableArray array];
    self.myConnections = [NSMutableArray array];
    self.childObjectIDs = [NSMutableSet set];
    self.childPortIDs = [NSMutableSet set];
    self.calculateBlocks = [NSMutableDictionary dictionary];
    self.calculateBlockTargets = [NSMutableDictionary dictionary];
    [self setupPorts];
}

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hotInlet = YES;
    hotInlet.parent = self;
    BbInlet *coldInlet = [[BbInlet alloc]init];
    coldInlet.parent = self;
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    mainOutlet.parent = self;
    [self addOutlet:mainOutlet];
    [self addHotInlet:hotInlet targetOutlet:mainOutlet calculateBlock:nil];
    [self addInlet:coldInlet];
}

+ (BbCalculateBlock)passThruCalculateBlock
{
    BbCalculateBlock block = ^( id value ){
        return value;
    };
    
    return block;
}

- (void)setupWithArguments:(id)arguments {}

#pragma mark - Port management & accessors

//These methods will be overridden in BbPatch so we can manage the order in which the inlets are returned.

- (NSArray *)inlets
{
    NSArray *inlets = ( nil != self.myInlets ) ? ( [NSArray arrayWithArray:self.myInlets] ) : ( nil );
    return inlets;
}

- (NSArray *)outlets
{
    NSArray *outlets = ( nil != self.myOutlets ) ? ( [NSArray arrayWithArray:self.myOutlets] ) : ( nil );
    return outlets;
}

- (NSArray *)children
{
    NSArray *children = ( nil != self.myChildren ) ? ( [NSArray arrayWithArray:self.myChildren] ) : ( nil );
    return children;
}

- (NSArray *)connections
{
    NSArray *connections = ( nil != self.myConnections ) ? ( [NSArray arrayWithArray:self.myConnections] ) : ( nil );
    return connections;
}

- (BOOL)addHotInlet:(BbInlet *)inlet targetOutlet:(BbOutlet *)outlet calculateBlock:(BbCalculateBlock)block
{
    if ( nil == inlet ) {
        return NO;
    }
    
    [self addInlet:inlet];
    
    if ( nil == block ) {
        self.calculateBlocks[inlet.uniqueID] = [BbObject passThruCalculateBlock];
    }else{
        self.calculateBlocks[inlet.uniqueID] = [block copy];
    }
    
    if ( nil != outlet ) {
        inlet.targetOutletID = outlet.uniqueID;
        self.calculateBlockTargets[outlet.uniqueID] = outlet;
    }
    
    
    return YES;
}

- (BOOL)addInlet:(BbInlet *)inlet {
    
    if ( nil == inlet || [self hasChildPortWithID:inlet.uniqueID] ) {
        return NO;
    }
    
    [self.myInlets addObject:inlet];
    [self.childPortIDs addObject:inlet.uniqueID];
    
    if ( inlet.isHotInlet ) {
        [inlet addObserver:self forKeyPath:kOutputElement options:NSKeyValueObservingOptionNew context:BbObjectContextXX];
    }
    
    return YES;
}


- (BOOL)addOutlet:(BbOutlet *)outlet {
    
    if ( nil == outlet || [self hasChildPortWithID:outlet.uniqueID] ) {
        return NO;
    }
    [self.myOutlets addObject:outlet];
    [self.childPortIDs addObject:outlet.uniqueID];
    return YES;
}

- (BbInlet *)removeInletAtIndex:(NSUInteger)index {
    
    if ( index >= self.inlets.count ) {
        return nil;
    }
    
    BbInlet *inlet = [self.myInlets objectAtIndex:index];
    [self.myInlets removeObjectAtIndex:index];
    [self.childPortIDs removeObject:inlet.uniqueID];
    
    if ( inlet.isHotInlet ) {
        [self removeHandlersAndTargetsForInlet:inlet];
    }
    
    return inlet;
}

- (void)removeHandlersAndTargetsForInlet:(BbInlet *)inlet
{
    [inlet removeObserver:self forKeyPath:@"outputElement" context:BbObjectContextXX];
    
    if ( [self.calculateBlocks.allKeys containsObject:inlet.uniqueID] ) {
        [self.calculateBlocks removeObjectForKey:inlet.uniqueID];
    }
    
    if ( nil != inlet.targetOutletID ) {
        if ( [self.calculateBlockTargets.allKeys containsObject:inlet.targetOutletID] ) {
            [self.calculateBlockTargets removeObjectForKey:inlet.targetOutletID];
        }
    }
}

- (BbOutlet *)removeOutletAtIndex:(NSUInteger)index {
    if ( index >= self.outlets.count ){
        return nil;
    }
    
    BbOutlet *outlet = [self.myOutlets objectAtIndex:index];
    [self.myOutlets removeObjectAtIndex:index];
    [self.childPortIDs removeObject:outlet.uniqueID];
    
    if ( [self.calculateBlockTargets.allKeys containsObject:outlet.uniqueID ] ) {
        [self.calculateBlockTargets removeObjectForKey:outlet.uniqueID];
    }
    
    return outlet;
}

- (BOOL)insertInlet:(BbInlet *)inlet atIndex:(NSUInteger)index {

    if ( nil == inlet || [self hasChildPortWithID:inlet.uniqueID] || index > self.inlets.count ) {
        return NO;
    }
    
    [self.myInlets insertObject:inlet atIndex:index];
    [self.childPortIDs addObject:inlet.uniqueID];
    
    return YES;
}

- (BOOL)insertOutlet:(BbOutlet *)outlet atIndex:(NSUInteger)index {
    if (nil == outlet || [self hasChildPortWithID:outlet.uniqueID] || index > self.outlets.count ) {
        return NO;
    }
    
    [self.myOutlets insertObject:outlet atIndex:index];
    [self.childPortIDs addObject:outlet.uniqueID];
    return YES;
}

- (BOOL)addChildObject:(BbObject<BbObjectChild>*)child
{
    if ( [self.myChildren containsObject:child] ) {
        return NO;
    }
    
    [self.myChildren addObject:child];
    return YES;
}

- (BbObject<BbObjectChild>*)removeChildObject:(BbObject<BbObjectChild>*)child
{
    if ( [self.myChildren containsObject:child]==NO) {
        return NO;
    }
    
    [self removeChildObject:child];
    return child;
}

- (BOOL)addConnection:(BbConnection *)connection
{
    if ( [self.myConnections containsObject:connection] ) {
        return NO;
    }
    
    BOOL success = [connection connectInParent:self];
    if ( success ) {
        [self.myConnections addObject:connection];
    }
    
    return success;
}

- (BbConnection *)removeConnection:(BbConnection *)connection
{
    if ( [self.myConnections containsObject:connection] == NO ) {
        return NO;
    }
    
    [self.myConnections removeObject:connection];
    [connection disconnect];
    return connection;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == BbObjectContextXX) {
        if ( [object isKindOfClass:[BbInlet class]] ) {
            BbInlet *inlet = (BbInlet *)object;
            BbCalculateBlock calculateBlock = nil;
            BbOutlet *targetOutlet = nil;
            if ( [self.calculateBlocks.allKeys containsObject:inlet.uniqueID] ) {
                calculateBlock = self.calculateBlocks[inlet.uniqueID];
                if ( nil != inlet.targetOutletID && [self.calculateBlockTargets.allKeys containsObject:inlet.targetOutletID] ) {
                    targetOutlet = self.calculateBlockTargets[inlet.targetOutletID];
                    targetOutlet.inputElement = calculateBlock(change[@"new"]);
                }else{
                    calculateBlock(change[@"new"]);
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - BbObjectChild

- (NSUInteger)indexInParent
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChild:self];
}

#pragma mark - BbObjectParent

- (BOOL)hasChildPortWithID:(NSString *)uniqueID
{
    if ( nil == uniqueID ) {
        return NO;
    }
    
    return [self.childPortIDs containsObject:uniqueID];
}

- (BOOL)hasChildObjectWithID:(NSString *)uniqueID
{
    if ( nil == uniqueID ) {
        return NO;
    }
    
    return [self.childObjectIDs containsObject:uniqueID];
}

- (BOOL)hasConnectionWithID:(NSString *)uniqueID
{
    if ( nil == uniqueID ) {
        return NO;
    }
    
    return NO;
}

- (NSString *)uniqueID:(id<BbObjectChild>)sender
{
    return self.uniqueID;
}

- (NSUInteger)indexOfChild:(id<BbObjectChild>)sender
{
    if ( nil == sender ) {
        return BbIndexInParentNotFound;
    }
    
    if ( [sender isKindOfClass:[BbObject class]] ) {
        if ( nil == self.children || ![self.myChildren containsObject:sender] ) {
            return BbIndexInParentNotFound;
        }else{
            return [self.children indexOfObject:sender];
        }
    }
    
    if ( [sender isKindOfClass:[BbInlet class]] ) {
        if ( nil == self.myInlets || ![self.myInlets containsObject:sender] ) {
            return BbIndexInParentNotFound;
        }else{
            return [self.myInlets indexOfObject:sender];
        }
    }
    
    if ( [sender isKindOfClass:[BbOutlet class]] ) {
        if ( nil == self.myOutlets || ![self.myOutlets containsObject:sender] ) {
            return BbIndexInParentNotFound;
        }else{
            return [self.myOutlets indexOfObject:sender];
        }
    }
    
    return BbIndexInParentNotFound;
    
}

- (BbObject *)childObjectWithID:(NSString *)uniqueID
{
    return nil;
}

- (BbPort *)childPortWithID:(NSString *)uniqueID
{
    return nil;
}
- (BbConnection *)childConnectionWithID:(NSString *)uniqueID
{
    return nil;
}

- (BOOL)connectionDidInvalidate:(BbConnection *)connection
{
    return NO;
}

+ (NSString *)myToken
{
    return @"#X";
}


- (BOOL)openView
{
    if ( nil == self.view ) {
        return NO;
    }
    
    for (BbObject *anObject in self.myChildren) {
        [self.view addSubview:[anObject createView]];
    }
    
    for (BbConnection *aConnection in self.myConnections) {
        [self.view addConnectionWithPoints:[aConnection connectionPoints]];
    }
    
    return YES;
}

- (id<BbObjectView>)createView
{
    self.view = [BbObject createViewWithArguments:self.viewArguments];
    
    for (BbInlet *anInlet in self.myInlets ) {
        anInlet.view = [self.view viewForInletAtIndex:[anInlet indexInParent]];
    }
    for (BbOutlet *anOutlet in self.myOutlets) {
        anOutlet.view = [self.view viewForOutletAtIndex:[anOutlet indexInParent]];
    }
    
    return self.view;
}

- (BOOL)closeView
{
    if ( nil != self.view ) {
        [self.view removeFromSuperView];
    }
    
    self.view = nil;
    
    return YES;
}

- (NSString *)textDescription
{
    NSMutableArray *myComponents = [NSMutableArray array];
    [myComponents addObject:[BbObject myToken]];
    
    NSString *view = nil;
    
    if ( nil != self.view ) {
        view = NSStringFromClass([self.view class]);
    }else{
        view = [BbObject myViewClass];
    }
    
    [myComponents addObject:view];
    
    NSString *position = nil;
    
    if ( nil != self.view ) {
        position = [BbHelpers position2String:[self.view objectViewPosition:self]];
    }else{
        position = [BbHelpers position2String:nil];
    }
    
    [myComponents addObject:position];
    
    NSString *className = NSStringFromClass([self class]);
    [myComponents addObject:className];
    
    NSString *argsString = nil;
    
    if ( nil != self.arguments ) {
        argsString = self.arguments;
        [myComponents addObject:argsString];
    }
    NSString *endOfLine = @";\n";
    NSString *myDescription = [[myComponents componentsJoinedByString:@" "]stringByAppendingString:endOfLine];
    NSMutableString *mutableString = [NSMutableString stringWithString:myDescription];
    
    if ( self.myChildren ) {
        for (BbObject *aChild in self.myChildren ) {
            
            [mutableString appendFormat:@"\t%@",[aChild textDescription]];
        }
    }
    
    if ( nil != self.connections ) {
        for (BbConnection *aConnection in self.myConnections ) {
            
            [mutableString appendString:[aConnection textDescription]];
        }
    }
    
    return [NSString stringWithString:mutableString];
    
}


- (void)dealloc
{
    NSMutableArray *children = _myChildren.mutableCopy;
    for ( NSUInteger i = 0; i < children.count ;  i ++) {
        BbObject *child = _myChildren[i];
        child = nil;
    }
    
    _myChildren = nil;
    
    NSMutableArray *connections = _myConnections.mutableCopy;
    for ( NSUInteger i = 0; i < connections.count; i ++ ) {
        BbConnection *connection = connections[i];
        [connection disconnect];
    }
    
    _myConnections = nil;
    
    NSMutableArray *inlets = _myInlets.mutableCopy;
    for (NSUInteger i = 0; i < inlets.count; i ++ ) {
        BbInlet *inlet = [self removeInletAtIndex:i];
        inlet = nil;
    }
    
    _myInlets = nil;
    
    NSMutableArray *outlets = _myOutlets.mutableCopy;
    for (NSUInteger i = 0 ; i < outlets.count; i++) {
        BbOutlet *outlet = [self removeOutletAtIndex:i];
        outlet = nil;
    }
    
    _myOutlets = nil;
    
    if ( nil != _view ) {
        [_view removeFromSuperView];
    }
    
    _view = nil;
    _calculateBlocks = nil;
    _calculateBlockTargets = nil;
}

@end
