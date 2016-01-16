//
//  BbRuntime+Methods.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeLookup.h"

@implementation BbRuntimeLookup (Methods)

+ (NSArray *)getMethodNamesForClass:(NSString *)className
{
    return [BbRuntimeLookup getMethodNamesForClass:className includePrivate:NO];
}

+ (NSArray *)getMethodNamesForClass:(NSString *)className includePrivate:(BOOL)incudePrivate
{
    Class class = NSClassFromString(className);
    unsigned int count = 0;
    Method *methods = class_copyMethodList(class, &count);
    if ( count == 0 ) {
        return nil;
    }
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
    
    for (unsigned int i = 0; i<count; i++) {
        Method aMethod = methods[i];
        SEL aSelector = method_getName(aMethod);
        NSString *selectorName = NSStringFromSelector(aSelector);
        if ( incudePrivate ) {
            [temp addObject:selectorName];
        }else{
            if ( ![selectorName hasPrefix:@"_"] ) {
                [temp addObject:selectorName];
            }
        }
    }
    
    free(methods);
    
    return [temp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
}


@end