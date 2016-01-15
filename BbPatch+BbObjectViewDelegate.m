//
//  BbPatch+BbObjectViewDelegate.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbPatch.h"

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
}

#pragma mark - Handle edits in textfield
- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)objectView
{
    if ( nil == objectView.dataSource ) {
        objectView.editingDelegate = self;
        return YES;
    }
    
    return NO;
}

- (void)objectView:(id<BbObjectView>)objectView didEditText:(NSString *)text
{
    NSLog(@"object view has text: %@",text);
}

- (BOOL)objectView:(id<BbObjectView>)objectView shouldEndEditingWithText:(NSString *)text
{
    NSArray *args = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *className = args.firstObject;
    NSLog(@"Object view ended editing with text: %@",text);
    
    return YES;
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
