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
    
    for ( id<BbEntity> anObject in _objects.mutableCopy ) {
        [self removeChildEntity:anObject];
    }
    
    _objects = nil;
    
    [self unloadChildConnectionPaths];
    [self unloadChildViews];
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
    
    if ( [entity isKindOfClass:[BbObject class]] ){
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
    
    if ( [entity isKindOfClass:[BbObject class]] ){
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
    if ( [entity isKindOfClass:[BbObject class]] ){
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
    
    if ([entity isKindOfClass:[BbObject class]] ){
        
        NSUInteger index = [entity indexInParentEntity];
        NSSet *connectionsToRemove = [entity childConnections];
        
        if ( nil != connectionsToRemove && connectionsToRemove.allObjects.count ) {
            
            for (BbConnection<BbEntity> *aConnection in connectionsToRemove.allObjects ) {
                if ( [aConnection.parent removeChildEntity:aConnection] ) {
                    [self.view removeConnectionPath:aConnection.path];
                }
            }
        }
        
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
    NSSet *connections = [self childConnections];
    if ( nil != connections ) {
        for (id<BbEntity> aConnection in connections.allObjects ) {
            NSString *depthString = [self depthStringForChild:aConnection];
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
    if ( nil == entity ) {
        return @"";
    }
    
    NSString *depthString = @"\t";
    
    if ( nil == self.parent ) {
        return depthString;
    }
    
    return [depthString stringByAppendingString:[self.parent depthStringForChild:self]];
}

- (NSSet *)childConnections
{
    NSMutableSet *childConnections = [NSMutableSet set];
    for (id<BbObject> anObject in self.objects ) {
        NSSet *connections = [anObject childConnections];
        if ( nil != connections ) {
            NSMutableSet *toAdd = [NSMutableSet setWithSet:connections];
            NSSet *existing = [NSSet setWithSet:childConnections];
            [toAdd minusSet:existing];
            [childConnections addObjectsFromArray:toAdd.allObjects];
        }
    }
    
    return [NSSet setWithSet:childConnections];
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

- (void)doSelectors
{
    [self doPendingSelectors:self.selectors];
}

- (void)doPendingSelectors:(NSArray *)selectors
{
    if ( nil == selectors || selectors.count == 0 ) {
        return;
    }
    NSMutableArray *selectorsCopy = selectors.mutableCopy;
    NSString *mySelector = selectorsCopy.firstObject;
    if ( [self respondsToSelector:NSSelectorFromString(mySelector)]) {
        [self performSelector:NSSelectorFromString(mySelector)];
    }
    
    [selectorsCopy removeObjectAtIndex:0];
    [self doPendingSelectors:selectorsCopy];
}

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

- (NSArray *)loadChildConnectionPaths
{
    NSSet *connections = [self childConnections];
    
    if ( nil == connections ) {
        return nil;
    }
    
    NSMutableArray *paths = [NSMutableArray arrayWithCapacity:connections.allObjects.count];
    for (BbConnection<BbConnection> *aConnection in connections.allObjects ) {
        id aPath = [aConnection loadPath];
        if ( nil != aPath ) {
            [paths addObject:aPath];
        }
    }
    return paths;
}

- (void)unloadChildConnectionPaths
{
    NSSet *connections = [self childConnections];
    if ( nil == connections ) {
        return;
    }
    
    for (BbConnection<BbConnection> *aConnection in connections.allObjects ) {
        [aConnection unloadPath];
    }
}

- (void)patchView:(id<BbPatchView>)sender didConnectOutletView:(id<BbEntityView>)outletView toInletView:(id<BbEntityView>)inletView
{
    BbConnection<BbConnection> *newConnection = [BbConnection connectionWithSender:outletView.entity receiver:inletView.entity];
    
    if ( [outletView.entity addChildEntity:newConnection] ) {
        id<BbConnectionPath> newPath = [newConnection loadPath];
        if ( nil != newPath && newPath.isValid ) {
            [sender addConnectionPath:newPath];
        }
    }else{
        NSAssert(newConnection.isConnected, @"ERROR MAKING CONNECTION");
    }
}

- (void)patchView:(id<BbPatchView>)sender didAddPlaceholderObjectView:(id<BbObjectView>)objectView
{
    [objectView beginEditingWithDelegate:self];
}

- (void)patchView:(id<BbPatchView>)sender didAddChildEntityView:(id<BbObjectView>)objectView
{
    id <BbObject> object = objectView.entity;
    BOOL ok = [self addChildEntity:object];
    NSAssert(ok, @"ERROR ADDING CHILD OBJECT");
}

- (void)patchView:(id<BbPatchView>)sender didAddChildConnection:(id<BbConnection>)connection {}

- (void)patchView:(id<BbPatchView>)sender didRemoveChildConnection:(id<BbConnection>)connection {}

- (void)patchView:(id<BbPatchView>)sender didRemoveChildObjectView:(id<BbObjectView>)objectView
{
    id <BbObject> object = objectView.entity;
    BOOL ok = [self removeChildEntity:object];
    NSAssert(ok,@"ERROR REMOVING CHILD ENTITY");
}

@end

@implementation BbPatch (BbObjectViewEditingDelegate)

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText
{
    if ( nil == self.symbolTable ) {
        self.symbolTable = [BbSymbolTable new];
    }
    
    
    NSArray *textComponents = [userText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchResults = [self.symbolTable BbText:self searchKeywordsForText:textComponents.firstObject];
    
    if ( nil != searchResults && searchResults.count > 0 ) {
        NSString *keyword = searchResults.firstObject;
        return [self.symbolTable BbText:self symbolForKeyword:keyword];
    }
    
    return nil;
}

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithUserText:(NSString *)userText
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText
{
    
    id<BbObject> oldObject = sender.entity;
    id<BbObject> newObject = [self createObjectIfNeededForView:sender withUserText:userText];
    [self.view updateAppearance];
}

- (id<BbObject>)createObjectIfNeededForView:(id<BbObjectView>)view withUserText:(NSString *)userText
{
    NSArray *textArray = [userText getComponents];
    NSString *keyWord = textArray.firstObject;
    NSArray *searchResults = [self.symbolTable BbText:self searchKeywordsForText:keyWord];
    
    if ( nil == searchResults ) {
        return nil;
    }
    
    NSString *symbol = [self.symbolTable BbText:self symbolForKeyword:searchResults.firstObject];
    
    if ( nil == symbol ) {
        return nil;
    }
    
    NSMutableArray *mutableTextArray = textArray.mutableCopy;
    [mutableTextArray replaceObjectAtIndex:0 withObject:symbol];
    NSString *creationArguments = [mutableTextArray getString];
    
    NSMutableArray *viewArgArray = [NSMutableArray array];
    NSString *viewClass = [NSInvocation doClassMethod:symbol selector:@"viewClass" arguments:nil];
    [viewArgArray addObject:viewClass];
    NSValue *position = [view position];
    NSString *positionString = NSStringFromCGPoint([position CGPointValue]);
    [viewArgArray addObjectsFromArray:[positionString getArguments]];
    NSString *viewArguments = [viewArgArray getString];
    id objectDescription = [BbObjectDescription objectDescriptionWithArgs:creationArguments viewArgs:viewArguments];
    BbObject *object = [NSClassFromString(symbol) objectWithDescription:objectDescription];
    return (id<BbObject>)object;
}

@end