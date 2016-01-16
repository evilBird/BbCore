//
//  NSObject+BbRuntime.h
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BbRuntime)

+ (id)uniqueClassInstance;
- (void)makeSubclass;
- (void)addMethodForSelector:(SEL)selector types:(const char *)types block:(id)block;

@end
