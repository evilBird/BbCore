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
            }else if ( [aDescription isKindOfClass:[BbPatchDescription class]]){
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

@end