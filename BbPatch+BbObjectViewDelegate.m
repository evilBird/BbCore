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

- (void)objectView:(id<BbObjectView>)sender didRequestPlaceholderViewAtPosition:(NSValue *)position
{
    
}

- (void)objectView:(id<BbObjectView>)sender didAddChildObjectView:(id<BbObjectView>)child
{
    
}

- (void)objectView:(id<BbObjectView>)sender didRemoveChildObjectView:(id<BbObjectView>)child
{
    
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
    
}

- (void)objectView:(id<BbObjectView>)sender didDisconnectPortView:(id<BbObjectView>)sendingPortView fromPortView:(id<BbObjectView>)receivingPortView
{
    
}

#pragma mark - Handle edits in textfield

- (void)objectView:(id<BbObjectView>)sender didEditWithEvent:(BbObjectViewEditingEvent)event
{
    
}

- (void)objectView:(id<BbObjectView>)sender textField:(id)textField didEditWithEvent:(BbObjectViewEditingEvent)event
{
    
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
