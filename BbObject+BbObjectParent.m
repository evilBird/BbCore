//
//  BbObject+BbObjectParent.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbObject.h"
#import "BbInlet.h"
#import "BbOutlet.h"
#import "BbConnection.h"

@implementation BbObject (BbObjectParent)

- (BOOL)isParentObject:(id<BbObjectChild>)child
{
    if ( [child isKindOfClass:[BbInlet class]] ) {
        return [self.myInlets containsObject:child];
    }
    
    if ( [child isKindOfClass:[BbOutlet class]] ) {
        return [self.myOutlets containsObject:child];
    }
    
    if ( [child isKindOfClass:[BbConnection class]] ){
        return [self.myConnections containsObject:child];
    }
    
    if ( [child isKindOfClass:[BbObject class]] ) {
        return [self.myChildren containsObject:child];
    }
    
    return NO;
}

- (BOOL)addChildObject:(id<BbObjectChild>)child
{
    if ( [self isParentObject:child] ) {
        return NO;
    }

    if ( [child isKindOfClass:[BbInlet class]] ) {
        [self.myInlets addObject:child];
        child.parent = self;
        [self didAddChildPort:child];
        return YES;
    }else if ( [child isKindOfClass:[BbOutlet class]] ){
        [self.myOutlets addObject:child];
        child.parent = self;
        [self didAddChildPort:child];
        return YES;
    }else if ( [child isKindOfClass:[BbConnection class]]){
        [self.myConnections addObject:child];
        child.parent = self;
        [self didAddChildConnection:(BbConnection *)child];
        return YES;
    }else if ( [child isKindOfClass:[BbObject class]]){
        [self.myChildren addObject:child];
        child.parent = self;
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index
{
    if ( [self isParentObject:child] ) {
        return NO;
    }
    if ( [child isKindOfClass:[BbInlet class]] && index <= self.myInlets.count ) {
        [self.myInlets insertObject:child atIndex:index];
        child.parent = self;
        [self didAddChildPort:child];
        return YES;
    }else if ( [child isKindOfClass:[BbOutlet class]] && index <= self.myOutlets.count ){
        [self.myOutlets insertObject:child atIndex:index];
        child.parent = self;
        [self didAddChildPort:child];
        return YES;
    }else if ( [child isKindOfClass:[BbConnection class]] && index <= self.myConnections.count ){        
        [self.myConnections insertObject:child atIndex:index];
        child.parent = self;
        [self didAddChildConnection:(BbConnection *)child];
        return YES;
    }else if ( [child isKindOfClass:[BbObject class]] && index <= self.myChildren.count ){
        [self.myChildren insertObject:child atIndex:index];
        child.parent = self;
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)removeChildObject:(id<BbObjectChild>)child
{
    if ( ![self isParentObject:child] ) {
        return NO;
    }
    
    if ( [child isKindOfClass:[BbInlet class]] ) {
        [self.myInlets removeObject:child];
        child.parent = nil;
        [self didRemoveChildPort:child];
        return YES;
    }else if ( [child isKindOfClass:[BbOutlet class]] ){
        [self.myOutlets removeObject:child];
        child.parent = nil;
        [self didRemoveChildPort:child];
        return YES;
    }else if ( [child isKindOfClass:[BbConnection class]]){
        [self.myConnections removeObject:child];
        child.parent = nil;
        [self didRemoveChildConnection:(BbConnection *)child];
        return YES;
    }else if ( [child isKindOfClass:[BbObject class]]){
        [self.myChildren removeObject:child];
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
        return [self.myInlets indexOfObject:child];
    }else if ( [child isKindOfClass:[BbOutlet class]] ){
        return [self.myOutlets indexOfObject:child];
    }else if ( [child isKindOfClass:[BbConnection class]] ){
        return [self.myConnections indexOfObject:child];
    }else if ( [child isKindOfClass:[BbObject class]] ){
        return [self.myChildren indexOfObject:child];
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

@end
