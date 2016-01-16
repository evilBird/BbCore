//
//  NSInvocation+Do.h
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSInvocation+BbRuntime.h"

@interface NSInvocation (Do)

+ (NSInvocation *)invocationForInstance:(id)target selector:(NSString *)selectorName arguments:(id)arguments;
+ (NSInvocation *)invocationForClass:(NSString *)className selector:(NSString *)selectorName arguments:(id)arguments;

+ (id)doInstanceMethod:(id)target selector:(NSString *)selectorName arguments:(id)arguments;
+ (id)doClassMethod:(NSString *)className selector:(NSString *)selectorName arguments:(id)arguments;

@end
