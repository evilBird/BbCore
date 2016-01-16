//
//  NSInvocation+BbRuntime.h
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (BbRuntime)

- (NSString *)getTypeString;
- (id)getReturnValueObject;
- (NSArray *)getArgumentObjects;
- (id)getObjectArgumentAtIndex:(NSUInteger)index;

- (void)setArgumentsWithObjects:(id)objects;
- (void)setArgumentAtIndex:(NSUInteger)index withObject:(id)object;
- (void)setArgumentAtIndex:(NSUInteger)index withArray:(NSArray *)array;

@end
