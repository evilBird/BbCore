//
//  NSInvocation+Do.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "NSInvocation+Do.h"
#import "NSInvocation+BbRuntime.h"

@implementation NSInvocation (Do)

+ (NSInvocation *)invocationForInstance:(id)target selector:(NSString *)selectorName arguments:(id)arguments
{
    if ( nil == target || nil == selectorName ) {
        return nil;
    }
    
    SEL selector = NSSelectorFromString(selectorName);
    NSMethodSignature *methodSignature = [[target class] instanceMethodSignatureForSelector:selector];
    
    if ( nil == methodSignature ) {
        return nil;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = selector;
    invocation.target = target;
    [invocation setArgumentsWithObjects:arguments];
    return invocation;
}

+ (id)doInstanceMethod:(id)target selector:(NSString *)selectorName arguments:(id)arguments
{
 
    NSInvocation *invocation = [NSInvocation invocationForInstance:target selector:selectorName arguments:arguments];
    
    if ( nil == invocation ) {
        return nil;
    }
    
    [invocation invoke];
    
    if ( invocation.methodSignature.isOneway ) {
        return nil;
    }
    
    return [invocation getReturnValueObject];
}

+ (NSInvocation *)invocationForClass:(NSString *)className selector:(NSString *)selectorName arguments:(id)arguments
{
    if ( nil == className || nil == selectorName ) {
        return nil;
    }
    
    Class c = NSClassFromString(className);
    
    if ( NULL == c ) {
        return nil;
    }
    
    SEL selector = NSSelectorFromString(selectorName);
    NSMethodSignature *methodSignature = [c methodSignatureForSelector:selector];
    
    if ( nil == methodSignature ) {
        return nil;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.target = c;
    invocation.selector = selector;
    [invocation setArgumentsWithObjects:arguments];
    return invocation;
}

+ (id)doClassMethod:(NSString *)className selector:(NSString *)selectorName arguments:(id)arguments
{
    NSInvocation *invocation = [NSInvocation invocationForClass:className selector:selectorName arguments:arguments];
    if ( nil == invocation ) {
        return nil;
    }
    
    [invocation invoke];
    
    if ( invocation.methodSignature.isOneway ) {
        return nil;
    }
    
    return [invocation getReturnValueObject];
}

@end
