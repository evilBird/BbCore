//
//  BbObject+Meta.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbRuntime.h"

@implementation BbObject (Meta)

+ (BbObject *)createObject:(NSString *)className arguments:(NSString *)arguments
{
    BbObject *object = [NSInvocation doClassMethod:className selector:@"alloc" arguments:nil];
    NSArray *args = ( nil != arguments ) ? ( @[arguments] ) : nil;
    [NSInvocation doInstanceMethod:object selector:@"initWithArguments:" arguments:args];
    return object;
}

+ (id<BbObjectView>)createView:(NSString *)className dataSource:(id<BbObjectViewDataSource>)dataSource
{
    id<BbObjectView> view = nil;
    view = [NSInvocation doClassMethod:className selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:view selector:@"initWithDataSource:" arguments:@[dataSource]];
    return view;
}

@end


