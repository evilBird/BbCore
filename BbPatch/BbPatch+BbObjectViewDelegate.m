//
//  BbPatch+BbObjectViewDelegate.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbPatch.h"
#import "BbTextDescription.h"
#import "BbPatchInlet.h"
#import "BbPatchOutlet.h"

@implementation BbPatch (BbObjectViewDelegate)

- (void)objectView:(id<BbObjectView>)sender didChangePosition:(NSValue *)position {}

- (void)objectView:(id<BbObjectView>)sender didChangeContentOffset:(NSValue *)offset
{
    self.viewArguments = [BbHelpers updateViewArgs:self.viewArguments withOffset:offset];
}

- (void)objectView:(id<BbObjectView>)sender didChangeZoomScale:(NSValue *)zoomScale
{
    self.viewArguments = [BbHelpers updateViewArgs:self.viewArguments withZoomScale:zoomScale];
}

- (void)objectView:(id<BbObjectView>)sender didChangeSize:(NSValue *)viewSize
{
    self.viewArguments = [BbHelpers updateViewArgs:self.viewArguments withSize:viewSize];
}

- (void)objectViewDidAppear:(id<BbObjectView>)sender
{
    if ( nil != self.mySelectors ) {
        NSLog(@"DOING SELECTORS: %@",self.mySelectors);
    }
}

#pragma mark - Add/remove child object views

- (void)objectView:(id<BbObjectView>)sender didAddChildObjectView:(id<BbObjectView>)child
{
    if ( nil == child.dataSource ) {
        child.editingDelegate = self;
        child.editing = YES;
    }else{
        id<BbObjectChild> object = (id<BbObjectChild>)[child dataSource];
        [self addChildObject:object];
    }
}

- (void)objectView:(id<BbObjectView>)sender didRemoveChildObjectView:(id<BbObjectView>)child
{
    if ( nil != child.dataSource && [self isParentObject:(id<BbObjectChild>)child.dataSource] ) {
        BbObject *object = (BbObject *)(child.dataSource);
        [self removeChildObject:object];
        object = nil;
    }
}

- (void)objectView:(id<BbObjectView>)sender didAddPortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope atIndex:(NSUInteger)index
{
    
}

- (void)objectView:(id<BbObjectView>)sender didRemovePortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope atIndex:(NSUInteger)index
{
    
}

- (void)objectView:(id<BbObjectView>)sender didMovePortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope toIndex:(NSUInteger)index
{
    
}

- (void)objectView:(id<BbObjectView>)sender didConnectPortView:(id<BbObjectView>)sendingPortView toPortView:(id<BbObjectView>)receivingPortView
{
    BbPort *sendingPort = (BbPort *)[sendingPortView dataSource];
    BbPort *receivingPort = (BbPort *)[receivingPortView dataSource];
    BbConnection *connection = [[BbConnection alloc]initWithSender:sendingPort receiver:receivingPort];
    [self addChildObject:connection];
}

- (void)objectView:(id<BbObjectView>)sender didDeleteConnection:(id<BbConnection>)connection
{
    [self removeChildObject:(id<BbObjectChild>)connection];
}

- (void)objectView:(id<BbObjectView>)sender didDisconnectPortView:(id<BbObjectView>)sendingPortView fromPortView:(id<BbObjectView>)receivingPortView
{
    BbPort *sendingPort = (BbPort *)[sendingPortView dataSource];
    BbPort *receivingPort = (BbPort *)[receivingPortView dataSource];
    NSPredicate *senderPredicate = [NSPredicate predicateWithFormat:@"senderID like %@",sendingPort.uniqueID];
    NSPredicate *receiverPredicate = [NSPredicate predicateWithFormat:@"receiverID like %@",receivingPort.uniqueID];
    NSArray *senderConnections = [self.connections filteredArrayUsingPredicate:senderPredicate];
    NSArray *receiverConnections = [self.connections filteredArrayUsingPredicate:receiverPredicate];
    if ( nil == senderConnections || nil == receiverConnections ) {
        return;
    }
    
    NSMutableSet *senderSet = [NSMutableSet setWithArray:senderConnections];
    NSSet *receiverSet = [NSSet setWithArray:receiverConnections];
    [senderSet intersectSet:receiverSet];
    
    if ( senderSet.allObjects.count ) {
        for ( BbConnection *connection in senderSet.allObjects ) {
            [self removeChildObject:connection];
        }
    }
    
    [sender updateAppearance];
}

#pragma mark - Handle edits in textfield

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)objectView
{
    if ( nil == objectView.dataSource ) {
        objectView.editingDelegate = self;
        return YES;
    }
    
    if ( [objectView canEdit] ) {
        objectView.editingDelegate = self;
        return YES;
    }
    
    return NO;
}

- (void)objectView:(id<BbObjectView>)objectView didEditText:(NSString *)text
{
    if ( ![objectView canReload] ) {
        return;
    }
    
    if ( nil == self.symbolTable ) {
        self.symbolTable = [BbSymbolTable new];
    }
    
    
    NSArray *textComponents = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *searchResults = [self.symbolTable BbText:self searchKeywordsForText:textComponents.firstObject];
    NSLog(@"\nSEARCHING %@...RESULTS: %@\n",text,[searchResults componentsJoinedByString:@" "]);
}

- (BOOL)objectView:(id<BbObjectView>)objectView shouldEndEditingWithText:(NSString *)text
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)objectView didEndEditingWithText:(NSString *)text
{
    
    NSArray *textArray = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *keyWord = textArray.firstObject;
    NSArray *searchResults = [self.symbolTable BbText:self searchKeywordsForText:keyWord];
    
    if ( nil == searchResults ) {
        return;
    }
    
    NSString *symbol = [self.symbolTable BbText:self symbolForKeyword:searchResults.firstObject];
    
    if ( nil == symbol ) {
        return;
    }
    
    NSString *viewClass = [NSInvocation doClassMethod:symbol selector:@"viewClass" arguments:nil];
    NSString *oldViewClass = NSStringFromClass([objectView class]);
    NSMutableArray *mutableTextArray = textArray.mutableCopy;
    [mutableTextArray replaceObjectAtIndex:0 withObject:symbol];
    NSString *objectArgs = [mutableTextArray componentsJoinedByString:@" "];
    
    NSMutableArray *viewArgArray = [NSMutableArray array];
    NSValue *position = [objectView objectViewPosition];
    [viewArgArray addObject:viewClass];
    [viewArgArray addObject:[BbHelpers updateViewArgs:@"0 0" withPosition:position]];
    NSString *viewArgs = [viewArgArray componentsJoinedByString:@" "];

    id objectDescription = [BbObjectDescription objectDescriptionWithArgs:objectArgs viewArgs:viewArgs];
    BbObject *object = [NSClassFromString(symbol) objectWithDescription:objectDescription];
    [self addChildObject:object];
    
    if ( [viewClass isEqualToString:oldViewClass] ) {
        object.view = objectView;
        objectView.delegate = object;
        [objectView setDataSource:object reloadViews:YES];
    }else{
        [self.view removeChildObjectView:objectView];
        [object loadView];
        [object.view setDelegate:object];
        [object.view setDataSource:object];
        [self.view addChildObjectView:object.view];
        [object.view updateAppearance];
        
        [self.view updateAppearance];
    }
}

#pragma mark - Editing state change handler

- (void)objectView:(id<BbObjectView>)sender didChangeEditState:(NSInteger)editState
{
    
}

#pragma mark - Editing actions

- (void)objectView:(id<BbObjectView>)sender didCopySelected:(NSArray*)selectedObjectViews
{
    
}

- (void)objectView:(id<BbObjectView>)sender didCutSelected:(NSArray*)selectedObjectViews
{
    
}

- (void)objectViewDidPasteCopied:(id<BbObjectView>)sender
{
    
}

- (void)objectView:(id<BbObjectView>)sender didAbstractSelected:(NSArray *)selectedObjectViews withArguments:(NSString *)arguments
{
    
}

#pragma mark - Target/Action type methods

- (void)sendActionsForObjectView:(id<BbObjectView>)sender
{
    
}

#pragma mark - Undo/Redo

- (BOOL)objectViewDidUndo:(id<BbObjectView>)sender
{
    return NO;
}

- (BOOL)objectViewDidRedo:(id<BbObjectView>)sender
{
    return NO;
}

#pragma mark - Open close selected object views

- (void)objectView:(id<BbObjectView>)sender didOpenChildView:(id<BbObjectView>)child
{
    
}

- (void)objectView:(id<BbObjectView>)sender didOpenHelpForChildView:(id<BbObjectView>)child
{
    
}

- (void)objectView:(id<BbObjectView>)sender didOpenTestForChildView:(id<BbObjectView>)child
{
    
}

- (void)objectView:(id<BbObjectView>)sender didCloseChildView:(id<BbObjectView>)child
{
    
}

@end