//
//  BbPatch+Meta.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPatch.h"
#import "BbTextDescription.h"
#import "BbRuntime.h"

@implementation BbPatch (Meta)

+ (BbPatch *)patchWithDescription:(BbPatchDescription *)description
{
    BbPatch *patch = (BbPatch *)[NSInvocation doClassMethod:description.objectClass selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:patch selector:@"initWithArguments:" arguments:description.objectArguments];
    patch.viewClass = description.viewClass;
    patch.viewArguments = description.viewArguments;
    patch.mySelectors = description.selectorDescriptions;
    
    if ( nil != description.childObjectDescriptions ) {
        for (id aDescription in description.childObjectDescriptions ) {
            if ( [aDescription isKindOfClass:[BbPatchDescription class]] ) {
                [patch addChildObject:[BbPatch patchWithDescription:aDescription]];
            }else if ( [aDescription isKindOfClass:[BbObjectDescription class]]){
                [patch addChildObject:[BbObject objectWithDescription:aDescription]];
            }else{
                NSLog(@"Unhandled description: %@",aDescription);
            }
        }
    }
    
    if ( nil != description.childConnectionDescriptions ) {
        for (BbConnectionDescription *aDescription in description.childConnectionDescriptions ) {
            BbConnection *connection = [patch connectionWithDescription:aDescription];
            [patch addChildObject:connection];
        }
    }
    
    [patch doSelectors];
    return patch;
}

- (BOOL)loadViews
{
    self.view = [NSInvocation doClassMethod:self.viewClass selector:@"createViewWithDataSource:" arguments:self];
    [self.view setDelegate:self];
    
    for ( id aChild in self.myChildren ) {
        if ( [aChild isKindOfClass:[BbPatch class]]) {
            [(BbPatch *)aChild loadViews];
            [self.view addChildObjectView:[(BbPatch *)aChild view]];
        }else if ( [aChild isKindOfClass:[BbObject class]]){
            [(BbObject *)aChild loadView];
            [self.view addChildObjectView:[(BbObject *)aChild view]];
        }
    }
    
    for ( id aConnection in self.myConnections ) {
        [(BbConnection *)aConnection createPathWithDelegate:self.view];
    }
    
    if ( nil != self.view ) {
        return YES;
    }
    
    return NO;
}

@end