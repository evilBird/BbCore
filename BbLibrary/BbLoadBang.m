//
//  BbLoadBang.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbLoadBang.h"

@implementation BbLoadBang

- (void)setupPorts
{
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"LoadBang";
    self.displayText = self.name;
}

- (void)loadBang
{
    [[self.outlets firstObject]setInputElement:[BbBang bang]];
}

+ (NSString *)symbolAlias
{
    return @"loadbang";
}


@end
