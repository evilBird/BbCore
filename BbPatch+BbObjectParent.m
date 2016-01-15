//
//  BbPatch+BbObjectParent.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/14/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatch.h"

@implementation BbPatch (BbObjectParent)

- (void)doSelectors
{
    [self doPendingSelectors:self.mySelectors];
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

- (BOOL)loadViews
{
    self.view = [NSInvocation doClassMethod:self.viewClass selector:@"createViewWithDataSource:" arguments:self];
    [self.view setDelegate:self];
    
    for ( id aChild in self.childObjects ) {
        if ( [aChild isKindOfClass:[BbPatch class]]) {
            [(BbPatch *)aChild loadViews];
            [self.view addChildObjectView:[(BbPatch *)aChild view]];
        }else if ( [aChild isKindOfClass:[BbObject class]]){
            [(BbObject *)aChild loadView];
            [self.view addChildObjectView:[(BbObject *)aChild view]];
        }
    }
    
    for ( BbConnection *aConnection in self.connections ) {
        [self.view addConnection:(id<BbConnection>)aConnection];
    }
    
    if ( nil != self.view ) {
        [self.view updateLayout];
        return YES;
    }
    
    return NO;
}

- (void)didAddChildConnection:(BbConnection *)connection
{
    if ( [connection validate] ) {
        BbPort *sender = connection.sender;
        BbPort *receiver = connection.receiver;
        [sender connectToPort:receiver];
        [self.view addConnection:(id<BbConnection>)connection];
    }else{
        [self removeChildObject:connection];
    }
}

- (void)didRemoveChildConnection:(BbConnection *)connection
{
    BbPort *sender = connection.sender;
    BbPort *receiver = connection.receiver;
    [sender disconnectFromPort:receiver];
    [self.view removeConnection:(id<BbConnection>)connection];
    connection = nil;
}

- (BOOL)isParentObject:(id<BbObjectChild>)child
{
    if ( [super isParentObject:child] ) {
        return YES;
    }
    
    if ( [child isKindOfClass:[BbConnection class]] ){
        return [self.connections containsObject:child];
    }
    
    if ( [child isKindOfClass:[BbObject class]] ) {
        return [self.childObjects containsObject:child];
    }
    
    return NO;
}

- (BOOL)addChildObject:(id<BbObjectChild>)child
{
    if ( [super addChildObject:child] ) {
        return YES;
    }
    
    if ( [child isKindOfClass:[BbConnection class]]){
        [self.connections addObject:child];
        child.parent = self;
        [self didAddChildConnection:(BbConnection *)child];
        return YES;
    }else if ( [child isKindOfClass:[BbObject class]]){
        [self.childObjects addObject:child];
        child.parent = self;
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index
{
    if ( [super insertChildObject:child atIndex:index] ) {
        return YES;
    }
    
    if ( [child isKindOfClass:[BbConnection class]] && index <= self.connections.count ){
        [self.connections insertObject:child atIndex:index];
        child.parent = self;
        [self didAddChildConnection:(BbConnection *)child];
        return YES;
    }else if ( [child isKindOfClass:[BbObject class]] && index <= self.connections.count ){
        [self.childObjects insertObject:child atIndex:index];
        child.parent = self;
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)removeChildObject:(id<BbObjectChild>)child
{
    if ( [super removeChildObject:child] ) {
        return YES;
    }
    
    if ( [child isKindOfClass:[BbConnection class]]){
        [self.connections removeObject:child];
        child.parent = nil;
        [self didRemoveChildConnection:(BbConnection *)child];
        return YES;
    }else if ( [child isKindOfClass:[BbObject class]]){
        [self.childObjects removeObject:child];
        child.parent = nil;
        return YES;
    }else{
        return NO;
    }
    
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
    }else if ( [child isKindOfClass:[BbConnection class]] ){
        return [self.connections indexOfObject:child];
    }else if ( [child isKindOfClass:[BbObject class]] ){
        return [self.childObjects indexOfObject:child];
    }
    
    return BbIndexInParentNotFound;
}

- (NSString *)depthStringForChildObject:(id<BbObjectChild>)child
{
    NSString *depthString = @"\t";
    if ( nil == self.parent ) {
        return depthString;
    }
    
    return [depthString stringByAppendingString:[self.parent depthStringForChildObject:self]];
}

- (NSString *)selectorText
{
    if ( nil == self.mySelectors ) {
        return @"";
    }
    NSMutableString *selectors = [NSMutableString string];
    NSString *depthString = nil;
    if ( nil != self.parent ) {
        depthString = [self.parent depthStringForChildObject:self];
    }else{
        depthString = @"";
    }
    for (NSString *aSelectorDescription in self.mySelectors ) {
        [selectors appendFormat:@"%@#S %@;\n",depthString,aSelectorDescription];
    }
    
    return selectors;
}

- (NSString *)textDescription
{
    NSString *myDescription = [super textDescription];
    NSMutableString *mutableString = [NSMutableString stringWithString:myDescription];
    if ( self.childObjects ) {
        for (BbObject *aChild in self.childObjects ) {
            NSString *depthString = [aChild.parent depthStringForChildObject:aChild];
            [mutableString appendFormat:@"%@%@",depthString,[aChild textDescription]];
        }
    }
    
    if ( nil != self.connections ) {
        for (BbConnection *aConnection in self.connections ) {
            NSString *depthString = [aConnection.parent depthStringForChildObject:aConnection];
            [mutableString appendFormat:@"%@%@",depthString,[aConnection textDescription]];
        }
    }
    
    NSString *selectorText = [self selectorText];
    if ( nil != selectorText ) {
        [mutableString appendString:selectorText];
    }
    
    return [NSString stringWithString:mutableString];
}

- (NSString *)descriptionToken
{
    return @"#N";
}

@end
