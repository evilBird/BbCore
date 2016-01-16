//
//  NSObject+BbRuntime.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "NSObject+BbRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (BbRuntime)

+ (id)uniqueClassInstance
{
    id instance = [NSObject new];
    [instance makeSubclass];
    return instance;
}

- (void) makeSubclass
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = NULL;
    if (uuid) {
        uuidString = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    const char *className = [[@[
                                NSStringFromClass([self class]),
                                (__bridge_transfer NSString *)uuidString
                                ] componentsJoinedByString:@"-"] UTF8String];
    
    Class subclass = objc_allocateClassPair([self class], className, 0);
    object_setClass(self, subclass);
}

- (void)addMethodForSelector:(SEL)selector types:(const char *)types block:(id)block
{
    class_addMethod([self class], selector, imp_implementationWithBlock(block), types);
}

@end
