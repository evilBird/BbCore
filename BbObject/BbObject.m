//
//  BbObject.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbTextDescription.h"

static void     *BbObjectContextXX      =       &BbObjectContextXX;

@interface BbObject ()

@property (nonatomic,strong)        NSHashTable         *memberOfConnections;

@end

@implementation BbObject

- (instancetype)initWithArguments:(NSString *)arguments
{
    self = [super init];
    if ( self ) {
        _creationArguments = arguments;
        [self commonInit];
        [self setupPorts];
        [self setupWithArguments:arguments];
    }
    
    return self;
}

- (void)commonInit
{
    self.displayText = nil;
    self.userText = nil;
    
    self.uniqueID = [NSString uniqueIDString];
    self.inlets = [NSMutableArray array];
    self.outlets = [NSMutableArray array];
    self.entityObservers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.memberOfConnections = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
}

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    BbInlet *coldInlet = [[BbInlet alloc]init];
    [self addChildEntity:coldInlet];
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
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

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description
{
    BbObject *object = (BbObject *)[NSInvocation doClassMethod:description.objectClass selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:object selector:@"initWithArguments:" arguments:description.objectArguments];
    object.viewArguments = description.viewArguments;
    return object;
}

- (NSUInteger)hash
{
    return [_uniqueID hash];
}

- (BOOL)isEqual:(id)object
{
    return ([self hash] == [object hash]);
}

- (void)dealloc
{
    [self removeAllEntityObservers];
    [self unloadView];

    for (id<BbEntity> anInlet in _inlets.mutableCopy ) {
        [self removeChildEntity:anInlet];
    }
    _inlets = nil;
    
    for (id<BbEntity> anOutlet in _outlets.mutableCopy ) {
        [self removeChildEntity:anOutlet];
    }
    
    _outlets = nil;
    
}

@end

#pragma mark - BbObject (BbEntityProtocol)

@implementation BbObject (BbEntityProtocol)

- (BOOL)addEntityObserver:(id<BbEntity>)entity
{
    if ( [self.entityObservers containsObject:entity] ) {
        return NO;
    }
    
    if ( [entity startObservingEntity:self] ) {
        
        [self.entityObservers addObject:entity];
        
        if ( [entity isKindOfClass:NSClassFromString(@"BbConnection")] ) {
            [self.memberOfConnections addObject:entity];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)removeEntityObserver:(id<BbEntity>)entity
{
    if ( ![self.entityObservers containsObject:entity] ) {
        return NO;
    }
    
    if ( [entity stopObservingEntity:self] ) {
        [self.entityObservers removeObject:self];
        if ( [self.memberOfConnections containsObject:entity] ) {
            [self.memberOfConnections removeObject:entity];
        }
        return YES;
    }
    
    return NO;
}

- (BOOL)startObservingEntity:(id<BbEntity>)entity
{
    return NO;
}

- (BOOL)stopObservingEntity:(id<BbEntity>)entity
{
    return NO;
}

- (BOOL)removeAllEntityObservers
{
    if ( !self.entityObservers.count ) {
        return YES;
    }
    
    NSMutableArray *observers = self.entityObservers.allObjects.mutableCopy;
    
    for (id<BbEntity>anObserver in observers ) {
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
    if ( nil == self.parent ){
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildEntity:self];
}

- (BOOL)isParentOfEntity:(id<BbEntity>)entity
{
    if ( nil == entity ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbInlet class]] ) {
        if ( nil == self.inlets || self.inlets.count == 0 ) {
            return NO;
        }else{
            NSSet *inletsSet = [NSSet setWithArray:self.inlets];
            return [inletsSet containsObject:entity];
        }
        
    }else if ( [entity isKindOfClass:[BbOutlet class]] ){
        if ( nil == self.outlets || self.outlets.count == 0 ) {
            return NO;
        }else{
            NSSet *outletsSet = [NSSet setWithArray:self.outlets];
            return [outletsSet containsObject:entity];
        }
    }
    
    return NO;
}

- (BOOL)addChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || [self isParentOfEntity:entity] ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbInlet class]] ) {
        [self.inlets addObject:entity];
        entity.parent = self;
        return YES;
    }else if ( [entity isKindOfClass:[BbOutlet class]] ){
        [self.outlets addObject:entity];
        entity.parent = self;
        return YES;
    }
    
    return NO;
}

- (BOOL)insertChildEntity:(id<BbEntity>)entity atIndex:(NSUInteger)index
{
    if ( nil == entity || [self isParentOfEntity:entity] ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbInlet class]] ) {
        if ( index > self.inlets.count ) {
            return NO;
        }else if ( index == self.inlets.count ){
            [self addChildEntity:entity];
            return YES;
        }else{
            [self.inlets insertObject:entity atIndex:index];
            entity.parent = self;
            return YES;
        }
    }else if ( [entity isKindOfClass:[BbOutlet class]] ){
        if ( index > self.outlets.count ) {
            return NO;
        }else if ( index == self.outlets.count ){
            [self addChildEntity:entity];
            return YES;
        }else{
            [self.outlets insertObject:entity atIndex:index];
            entity.parent = self;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)removeChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || [self isParentOfEntity:entity] == NO ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbInlet class]] ) {
        NSUInteger index = [entity indexInParentEntity];
        if ( index >= self.inlets.count ) {
            return NO;
        }
        [self.inlets removeObjectAtIndex:index];
        entity.parent = nil;
        return YES;
    }else if ( [entity isKindOfClass:[BbOutlet class]] ){
        NSUInteger index = [entity indexInParentEntity];
        if ( index >= self.outlets.count ) {
            return NO;
        }
        
        [self.outlets removeObjectAtIndex:index];
        entity.parent = nil;
        return YES;
    }
    return NO;
}

- (NSUInteger)indexOfChildEntity:(id<BbEntity>)entity
{
    if ( nil == entity || [self isParentOfEntity:entity] == NO ) {
        return BbIndexInParentNotFound;
    }
    if ( [entity isKindOfClass:[BbInlet class]] ) {
        return [self.inlets indexOfObject:entity];
    }else if ( [entity isKindOfClass:[BbOutlet class]] ){
        return [self.outlets indexOfObject:entity];
    }
    
    return BbIndexInParentNotFound;
}

- (BOOL)replaceChildEntity:(id<BbEntity>)entityToReplace withEntity:(id<BbEntity>)replacementEntity
{
    if ( nil == entityToReplace || nil == replacementEntity ){
        return NO;
    }
    if ( [self isParentOfEntity:entityToReplace] == NO || [self isParentOfEntity:replacementEntity] == YES ) {
        return NO;
    }
    
    NSUInteger index = [entityToReplace indexInParentEntity];
    if ( index == BbIndexInParentNotFound ) {
        return NO;
    }
    
    return ([self removeChildEntity:entityToReplace] && [self insertChildEntity:replacementEntity atIndex:index]);
    
}

- (NSString *)textDescription
{
    NSMutableArray *myComponents = [NSMutableArray array];
    
    [myComponents addObject:[self textDescriptionToken]];
    [myComponents addObject:[[self class] viewClass]];
    
    NSArray *viewArguments = [self.viewArguments getArguments];
    
    if ( nil != viewArguments && viewArguments.count ) {
        [myComponents addObjectsFromArray:viewArguments];
    }
    
    [myComponents addObject:NSStringFromClass([self class])];
    NSArray *creationArguments = [self.creationArguments getArguments];
    
    if ( nil != creationArguments ) {
        [myComponents addObjectsFromArray:creationArguments];
    }
        
    NSString *myComponentsString = [myComponents getString];
    NSString *myDescription = [[myComponentsString trimWhitespace]stringByAppendingString:@";\n"];
    return myDescription;
}

- (NSString *)textDescriptionToken
{
    return @"#X";
}

- (NSString *)depthStringForChild:(id<BbEntity>)entity
{
    return @"";
}

- (NSSet *)childConnections
{
    NSMutableSet *childConnections = [NSMutableSet set];

    for ( id<BbEntity> anOutlet in self.outlets ) {
        NSSet *connections = [anOutlet childConnections];
        if ( nil != connections ) {
            NSSet *existing = [NSSet setWithSet:childConnections];
            NSMutableSet *toAdd = [NSMutableSet setWithSet:connections];
            [toAdd minusSet:existing];
            [childConnections addObjectsFromArray:toAdd.allObjects];
        }
    }
    
    for ( id<BbEntity> anInlet in self.inlets ) {
        NSSet *connections = [anInlet childConnections];
        if ( nil != connections ) {
            NSSet *existing = [NSSet setWithSet:childConnections];
            NSMutableSet *toAdd = [NSMutableSet setWithSet:connections];
            [toAdd minusSet:existing];
            [childConnections addObjectsFromArray:toAdd.allObjects];
        }
    }
    
    return [NSSet setWithSet:childConnections];
}

@end

#pragma mark - BbObject (BbObjectProtocol)

@implementation BbObject (BbObjectProtocol)

- (id<BbObjectView>)loadView
{
    NSString *viewClass = [[self class] viewClass];
    NSArray *argumentArray = @[self];
    self.view = [NSInvocation doClassMethod:viewClass selector:@"viewWithEntity:" arguments:argumentArray];
    if ( nil != self.view ) {
        
        NSArray *childViews = [self loadChildViews];
        
        for (id<BbEntityView> aChildView in childViews ) {
            [self.view addChildEntityView:aChildView];
        }
    }
    
    return _view;
}

- (NSArray *)loadChildViews
{
    NSMutableArray *childViews = [NSMutableArray arrayWithCapacity:(self.inlets.count+self.outlets.count)];
    
    for (id<BbEntity> inlet in self.inlets ) {
        id<BbEntityView> inletView = [inlet loadView];
        inlet.view = inletView;
        inletView.entity = inlet;
        [childViews addObject:inletView];
    }
    
    for (id<BbEntity> outlet in self.outlets) {
        id<BbEntityView> outletView = [outlet loadView];
        outlet.view = outletView;
        outletView.entity = outlet;
        [childViews addObject:outletView];
    }
    return childViews;
}

- (void)unloadView
{
    if ( nil == self.view ) {
        return;
    }

    [self unloadChildViews];
    
    id<BbObjectView> parentView = (id<BbObjectView>)self.parent.view;
    [parentView removeChildEntityView:self.view];
    
    self.view = nil;
}

- (void)unloadChildViews
{
    for (id<BbEntity> inlet in self.inlets ) {
        [inlet unloadView];
    }
    
    for (id<BbEntity> outlet in self.outlets ) {
        [outlet unloadView];
    }
}

- (BOOL)objectView:(id<BbObjectView>)sender didChangeValue:(NSValue *)value forViewArgumentKey:(NSString *)key
{
    if (!value) {
        return NO;
    }
    
    if ( [key isEqualToString:kViewArgumentKeyPosition] ) {
        NSString *valueString = [BbHelpers viewArgsFromPosition:value];
        self.viewArguments = valueString;
        return YES;
    }
    return NO;
}

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)sender
{
    return YES;
}

- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender
{
    if ( [self.parent conformsToProtocol:NSProtocolFromString(@"BbObjectViewEditingDelegate")]) {
        return (id<BbObjectViewEditingDelegate>)self.parent;
    }
    
    return nil;
}

- (void)objectView:(id<BbObjectView>)sender didBeginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)editingDelegate {}

@end

@implementation BbObject (BbObjectEditingDelegate)

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText
{
    self.userText = userText;
}

@end
