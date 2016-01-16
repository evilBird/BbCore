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
        [self setupPorts];
        [self setupWithArguments:arguments];
    }
    
    return self;
}

- (void)commonInit
{
    self.uniqueID = [BbHelpers createUniqueIDString];
    self.inlets = [NSMutableArray array];
    self.outlets = [NSMutableArray array];
    self.observers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
}

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hotInlet = YES;
    [self addChildObject:hotInlet];
    BbInlet *coldInlet = [[BbInlet alloc]init];
    [self addChildObject:coldInlet];
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildObject:mainOutlet];
    hotInlet.outputBlock = ^(id value){
        mainOutlet.inputElement = value;
    };
}

- (void)setupWithArguments:(id)arguments {
    self.name = NSStringFromClass([self class]);
}

+ (NSString *)symbolAlias
{
    return @"Object";
}

+ (NSString *)viewClass
{
    return @"BbView";
}

- (void)dealloc
{
    
    [self removeAllObjectObservers];
    
    for (BbInlet *anInlet in _inlets.mutableCopy ) {
        [self removeChildObject:anInlet];
    }
    _inlets = nil;
    
    for (BbOutlet *anOutlet in _outlets.mutableCopy ) {
        [self removeChildObject:anOutlet];
    }
    
    _outlets = nil;
    
    if ( nil != _view ) {
        [_view removeFromSuperview];
    }
    
    _view = nil;
}

@end


#pragma mark - BbObject

@implementation BbObject (BbObject)

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

- (void)loadBang
{
    
}

@end

#pragma mark - BbObjectChild

@implementation BbObject (BbObjectChild)

- (BOOL)loadView
{
    self.view = [NSInvocation doClassMethod:[[self class] viewClass] selector:@"createViewWithDataSource:" arguments:self];
    self.view.delegate = self;
    if ( nil != self.view ) {
        
        for (NSUInteger i = 0 ; i < self.inlets.count ; i ++ ) {
            id<BbObjectView> view = [self.view viewForInletAtIndex:i];
            [self.inlets[i]setView:view];
            [view setDataSource:self.inlets[i]];
        }
        
        for (NSUInteger i = 0; i < self.outlets.count; i++) {
            id<BbObjectView> view = [self.view viewForOutletAtIndex:i];
            [self.outlets[i]setView:view];
            [view setDataSource:self.outlets[i]];
        }
        
        return YES;
    }
    
    return NO;
}

- (NSUInteger)indexInParent
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildObject:self];
}

- (NSString *)descriptionToken
{
    return @"#X";
}

- (NSString *)textDescription
{
    NSMutableArray *myComponents = [NSMutableArray array];
    
    [myComponents addObject:[self descriptionToken]];
    [myComponents addObject:self.viewClass];
    
    if ( nil != self.viewArguments ) {
        [myComponents addObjectsFromArray:[self.viewArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    
    [myComponents addObject:NSStringFromClass([self class])];
    
    if ( nil != self.objectArguments ) {
        [myComponents addObjectsFromArray:[self.objectArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    NSString *endOfLine = @";\n";
    [myComponents addObject:endOfLine];
    
    NSString *myDescription = [myComponents componentsJoinedByString:@" "];
    
    return myDescription;
}

@end

#pragma mark - BbObjectParent

@implementation BbObject (BbObjectParent)

- (BOOL)isParentObject:(id<BbObjectChild>)child
{
    if ( [child isKindOfClass:[BbInlet class]] ) {
        return [self.inlets containsObject:child];
    }
    
    if ( [child isKindOfClass:[BbOutlet class]] ) {
        return [self.outlets containsObject:child];
    }
    
    return NO;
}

- (BOOL)addChildObject:(id<BbObjectChild>)child
{
    if ( [self isParentObject:child] ) {
        return NO;
    }
    
    if ( [child isKindOfClass:[BbInlet class]] ) {
        [self.inlets addObject:child];
        child.parent = self;
        return YES;
    }else if ( [child isKindOfClass:[BbOutlet class]] ){
        [self.outlets addObject:child];
        child.parent = self;
        return YES;
    }
    
    return NO;
}

- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index
{
    if ( [self isParentObject:child] ) {
        return NO;
    }
    
    if ( [child isKindOfClass:[BbInlet class]] && index <= self.inlets.count ) {
        [self.inlets insertObject:child atIndex:index];
        child.parent = self;
        return YES;
    }else if ( [child isKindOfClass:[BbOutlet class]] && index <= self.outlets.count ){
        [self.outlets insertObject:child atIndex:index];
        child.parent = self;
        return YES;
    }
    
    return NO;
}

- (BOOL)removeChildObject:(id<BbObjectChild>)child
{
    if ( ![self isParentObject:child] ) {
        return NO;
    }
    
    if ( [child isKindOfClass:[BbInlet class]] ) {
        [self.inlets removeObject:child];
        child.parent = nil;
        return YES;
    }else if ( [child isKindOfClass:[BbOutlet class]] ){
        [self.outlets removeObject:child];
        child.parent = nil;
        return YES;
    }
    
    return NO;
}

- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child
{
    if ( ![self isParentObject:child] ) {
        return BbIndexInParentNotFound;
    }
    
    if ( [child isKindOfClass:[BbInlet class]] ) {
        return [self.inlets indexOfObject:child];
    }else if ( [child isKindOfClass:[BbOutlet class]] ){
        return [self.outlets indexOfObject:child];
    }
    
    return BbIndexInParentNotFound;
}

@end