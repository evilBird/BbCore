//
//  BbRuntime+Class.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeLookup.h"

@implementation BbRuntimeLookup (Classes)

+ (NSArray *)getClassNames
{
    return [BbRuntimeLookup getClassNamesIncludePrivate:NO];
}

+ (NSArray *)getClassNamesIncludePrivate:(BOOL)includePrivate
{
    unsigned int count;
    objc_copyClassList(&count);
    Class *buffer = (Class *)malloc(sizeof(Class)*count);
    objc_getClassList(buffer, count);
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        Class aClass = buffer[i];
        NSString *className = NSStringFromClass(aClass);
        if ( includePrivate) {
            [temp addObject:className];
        }else{
            if ( ![className hasPrefix:@"_"] ) {
                [temp addObject:className];
            }
        }
    }
    if ( count > 0 ) {
        free(buffer);
    }
    return [NSArray arrayWithArray:[temp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}

@end
