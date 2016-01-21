//
//  BbPatch.m
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatch.h"

@implementation BbPatch

- (void)commonInit
{
    [super commonInit];
    self.objects = [NSMutableArray array];
    self.connections = [NSMutableArray array];
    self.selectors = [NSMutableArray array];
}

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments {}

+ (NSString *)viewClass
{
    return @"BbPatchView";
}

- (void)dealloc
{
    [self removeAllEntityObservers];
    
    for (id<BbEntity> anInlet in self.inlets.mutableCopy ) {
        [self removeChildEntity:anInlet];
    }
    
    self.inlets = nil;
    
    for (id<BbEntity> anOutlet in self.outlets.mutableCopy ) {
        [self removeChildEntity:anOutlet];
    }
    
    self.outlets = nil;
    
    for ( id<BbEntity> aConnection in _connections.mutableCopy ) {
        [self removeChildEntity:aConnection];
    }
    
    _connections = nil;
    
    for ( id<BbEntity> anObject in _objects.mutableCopy ) {
        [self removeChildEntity:anObject];
    }
    
    _objects = nil;
    
    [self unloadView];
}

@end

@implementation BbPatch (BbEntityProtocol)

- (BOOL)isParentOfEntity:(id<BbEntity>)entity
{
    if ( [super isParentOfEntity:entity] ) {
        return YES;
    }
    
    if ( nil == entity ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbConnection class]] ) {
        if ( nil == self.connections || self.connections.count == 0 ) {
            return NO;
        }else{
            NSSet *connections = [NSSet setWithArray:self.connections];
            return [connections containsObject:entity];
        }
    }else if ( [entity isKindOfClass:[BbObject class]] ){
        if ( nil == self.objects || self.objects.count == 0 ) {
            return NO;
        }else{
            NSSet *objects = [NSSet setWithArray:self.objects];
            return [objects containsObject:entity];
        }
    }
    return NO;
}

- (BOOL)addChildEntity:(id<BbEntity>)entity
{
    if ( [super addChildEntity:entity] ) {
        return YES;
    }
    
    if ( nil == entity || [self isParentOfEntity:entity] ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbConnection class]] ) {
        [self.connections addObject:entity];
        entity.parent = self;
        return YES;
    }else if ( [entity isKindOfClass:[BbObject class]] ){
        [self.objects addObject:entity];
        entity.parent = self;
        return YES;
    }
    
    return NO;
}

- (BOOL)insertChildEntity:(id<BbEntity>)entity atIndex:(NSUInteger)index
{
    if ( [super insertChildEntity:entity atIndex:index] ) {
        return YES;
    }
    
    if ( nil == entity || [self isParentOfEntity:entity] ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbConnection class]]) {
        if ( index > self.connections.count ) {
            return NO;
        }else if ( index == self.connections.count ){
            [self addChildEntity:entity];
            return YES;
        }else {
            [self.connections insertObject:entity atIndex:index];
            entity.parent = self;
            return YES;
        }
    }else if ( [entity isKindOfClass:[BbObject class]] ){
        if ( index > self.objects.count ) {
            return NO;
        }else if ( index == self.objects.count ){
            [self addChildEntity:entity];
            return YES;
        }else{
            [self.objects insertObject:entity atIndex:index];
            entity.parent = self;
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)removeChildEntity:(id<BbEntity>)entity
{
    if ( [super removeChildEntity:entity] ) {
        return YES;
    }
    
    if ( nil == entity || [self isParentOfEntity:entity] == NO ) {
        return NO;
    }
    
    if ( [entity isKindOfClass:[BbConnection class]] ) {
        NSUInteger index = [entity indexInParentEntity];
        [self.connections removeObjectAtIndex:index];
        entity.parent = nil;
        return YES;
    }else if ([entity isKindOfClass:[BbObject class]] ){
        NSUInteger index = [entity indexInParentEntity];
        [self.objects removeObjectAtIndex:index];
        entity.parent = nil;
        return YES;
    }
    
    return NO;
}

- (NSUInteger)indexOfChildEntity:(id<BbEntity>)entity
{
    if ( [super indexOfChildEntity:entity] != BbIndexInParentNotFound ) {
        return [super indexOfChildEntity:entity];
    }
    
    if ( nil == entity || [self isParentOfEntity:entity] == NO ) {
        return BbIndexInParentNotFound;
    }
    
    if ( [entity isKindOfClass:[BbConnection class]] ) {
        return [self.connections indexOfObject:entity];
    }
    
    if ( [entity isKindOfClass:[BbObject class]] ) {
        return [self.objects indexOfObject:entity];
    }
    
    return BbIndexInParentNotFound;
    
}

- (BOOL)replaceChildEntity:(id<BbEntity>)entityToReplace withEntity:(id<BbEntity>)replacementEntity
{
    return [super replaceChildEntity:entityToReplace withEntity:replacementEntity];
}

- (NSString *)selectorText
{
    
    NSMutableString *selectorText = [NSMutableString string];
    NSString *depthString = nil;
    
    if ( nil != self.parent ) {
        depthString = [self.parent depthStringForChild:self];
    }else{
        depthString = @"";
    }
    
    if ( nil == self.selectors ) {
        [selectorText appendFormat:@"%@#S loadChildViews;\n",depthString];
    }else{
        for (NSString *aSelectorDescription in self.selectors ) {
            [selectorText appendFormat:@"%@#S %@;\n",depthString,aSelectorDescription];
        }
    }
    
    return selectorText;
}

- (NSString *)textDescription
{
    NSString *myDescription = [super textDescription];
    NSMutableString *mutableString = [NSMutableString stringWithString:myDescription];
    if ( self.objects ) {
        for (id<BbObject> anObject in self.objects ) {
            NSString *depthString = [anObject.parent depthStringForChild:anObject];
            [mutableString appendFormat:@"%@%@",depthString,[anObject textDescription]];
        }
    }
    
    if ( nil != self.connections ) {
        for (id<BbEntity> aConnection in self.connections ) {
            NSString *depthString = [aConnection.parent depthStringForChild:aConnection];
            [mutableString appendFormat:@"%@%@",depthString,[aConnection textDescription]];
        }
    }
    
    NSString *selectorText = [self selectorText];
    
    if ( nil != selectorText ) {
        [mutableString appendString:selectorText];
    }
    
    return [NSString stringWithString:mutableString];
}

- (NSString *)textDescriptionToken
{
    return @"#N";
}

- (NSString *)depthStringForChild:(id<BbEntity>)entity
{
    if ( nil == entity || [self isParentOfEntity:entity] == NO ) {
        return [super depthStringForChild:entity];
    }
    
    NSString *depthString = @"\t";
    
    if ( nil == self.parent ) {
        return depthString;
    }
    
    return [depthString stringByAppendingString:[self.parent depthStringForChild:self]];
}

@end


@implementation BbPatch (BbObjectProtocol)

+ (NSString *)symbolAlias
{
    return @"Patch";
}

- (id<BbPatchView>)loadView
{
    NSString *viewClass = [[self class] viewClass];
    NSString *viewArguments = self.viewArguments;
    NSArray *argumentArray = @[self,viewArguments];
    self.view = [NSInvocation doClassMethod:viewClass selector:@"viewWithEntity:arguments:" arguments:argumentArray];
    return (id<BbPatchView>)self.view;
}

- (void)unloadView
{
    [super unloadView];
}

- (BOOL)objectView:(id<BbObjectView>)sender didChangeValue:(NSValue *)value forViewArgumentKey:(NSString *)key
{
    if ( [super objectView:sender didChangeValue:value forViewArgumentKey:key] ) {
        return YES;
    }
    
    NSString *viewArguments = self.viewArguments;
    
    if ( [key isEqualToString:kViewArgumentKeyContentOffset] ) {
        CGPoint point = value.CGPointValue;
        viewArguments = [viewArguments setArgument:@(point.x) atIndex:kViewArgumentIndexContentOffset_X];
        viewArguments = [viewArguments setArgument:@(point.y) atIndex:kViewArgumentIndexContentOffset_Y];
        self.viewArguments = viewArguments;
        return YES;
    }
    
    if ( [key isEqualToString:kViewArgumentKeySize] ) {
        CGSize size = value.CGSizeValue;
        viewArguments = [viewArguments setArgument:@(size.width) atIndex:kViewArgumentIndexSize_Width];
        viewArguments = [viewArguments setArgument:@(size.height) atIndex:kViewArgumentIndexSize_Height];
        self.viewArguments = viewArguments;
        return YES;
    }
    
    if ( [key isEqualToString:kViewArgumentKeyZoomScale] ) {
        CGFloat zoom = [(NSNumber *)value doubleValue];
        viewArguments = [viewArguments setArgument:@(zoom) atIndex:kViewArgumentIndexZoomScale];
        self.viewArguments = viewArguments;
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
    return [super editingDelegateForObjectView:sender];
}

- (void)objectView:(id<BbObjectView>)sender didBeginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)editingDelegate {}

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText {

}

@end


@implementation BbPatch (BbPatchProtocol)

- (NSArray *)loadChildViews
{
    if ( nil == self.objects ) {
        return nil;
    }
    NSMutableArray *childViews = [NSMutableArray arrayWithCapacity:self.objects.count];
    for (id<BbObject> anObject in self.objects ) {
        id<BbObjectView> aChildView = [anObject loadView];
        if ( nil != aChildView ) {
            [childViews addObject:aChildView];
            aChildView.parentView = self.view;
        }
    }
    
    return childViews;
}

- (void)unloadChildViews
{
    if ( nil == self.objects ) {
        return;
    }
    
    for (id<BbObject> anObject in self.objects ) {
        [anObject unloadView];
    }
    return;
}

- (NSArray *)loadChildConnections
{
    if ( nil == self.connections ) {
        return nil;
    }
    
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:self.connections.count];
    for (BbConnection<BbConnection> *aConnection in self.connections ) {
        id aPath = [aConnection loadPath];
        if ( nil != aPath ) {
            [paths addObject:aPath];
        }
    }
    return paths;
}

- (void)unloadChildConnections
{
    if ( nil == self.connections ) {
        return;
    }
    
    for (BbConnection<BbConnection> *aConnection in self.connections ) {
        [aConnection unloadPath];
    }
}

- (void)patchView:(id<BbPatchView>)sender didConnectOutletView:(id<BbEntityView>)outletView toInletView:(id<BbEntityView>)inletView
{
    BbConnection<BbConnection> *newConnection = 
}

- (void)patchView:(id<BbPatchView>)sender didAddPlaceholderObjectView:(id<BbObjectView>)objectView
{
    
}

- (void)patchView:(id<BbPatchView>)sender didAddChildObjectView:(id<BbObjectView>)objectView
{
    
}

- (void)patchView:(id<BbPatchView>)sender didAddChildConnection:(id<BbConnection>)connection
{
    
}

- (void)patchView:(id<BbPatchView>)sender didRemoveChildConnection:(id<BbConnection>)connection
{
    
}

- (void)patchView:(id<BbPatchView>)sender didRemoveChildObjectView:(id<BbObjectView>)objectView
{
    
}

@end

@implementation BbPatch (BbPatchViewEditingDelegate)

@end