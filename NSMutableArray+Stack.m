//
//  NSMutableArray+Stack.m
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

- (void)push:(id)object
{
    [self addObject:object];
}

- (id)pop
{
    if ( self.count == 0 ) {
        return nil;
    }
    NSUInteger lastIndex = self.count-1;
    id popped = self[lastIndex];
    [self removeObjectAtIndex:lastIndex];
    return popped;
}

@end
