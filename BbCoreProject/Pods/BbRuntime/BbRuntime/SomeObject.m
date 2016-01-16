//
//  SomeObject.m
//  Dynamic Delegate
//
//  Created by Travis Henspeter on 12/31/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "SomeObject.h"

@interface SomeObject ()

@property (nonatomic,weak)      Protocol        *myProtocol;

@end

@implementation SomeObject

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        _myProtocol = @protocol(SomeObjectProtocol);
    }
    
    return self;
}

- (void)tellDelegateSomething:(id)something
{
    [self.delegate someObject:self saysSomething:something];
}

- (void)askDelegateSomething
{
    NSString *something = @"Do you like me?";
    id response = [self.delegate someObject:self asksSomething:something];
    NSLog(@"Dynamic delegate %@ response: %@",self.delegate,response);
}

- (void)haveDelegateEchoNumber:(id)number
{
    NSUInteger numberToEcho = [(NSNumber *)number integerValue];
    NSUInteger response = [self.delegate someObject:self echoNumber:numberToEcho];
    NSLog(@"Dynamic delegate %@ echoed number: %@",self.delegate,@(response));
}

@end
