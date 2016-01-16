//
//  SomeObject.h
//  Dynamic Delegate
//
//  Created by Travis Henspeter on 12/31/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SomeObjectProtocol <NSObject>

- (void)someObject:(id)sender saysSomething:(id)something;
- (id)someObject:(id)sender asksSomething:(id)something;
- (NSUInteger)someObject:(id)sender echoNumber:(NSUInteger)number;

@end

@interface SomeObject : NSObject

@property   (nonatomic,weak)        id<SomeObjectProtocol>          delegate;

- (void)tellDelegateSomething:(id)something;
- (void)askDelegateSomething;
- (void)haveDelegateEchoNumber:(id)number;

@end
