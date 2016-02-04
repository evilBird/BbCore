//
//  BbCloseBang.m
//  Pods
//
//  Created by Travis Henspeter on 1/30/16.
//
//

#import "BbCloseBang.h"

@implementation BbCloseBang

- (void)setupPorts
{
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"CloseBang";
    self.displayText = self.name;
}

+ (NSString *)symbolAlias
{
    return @"closebang";
}

- (void)closeBang
{
    [self.outlets.firstObject setInputElement:[BbBang bang]];
}

@end
