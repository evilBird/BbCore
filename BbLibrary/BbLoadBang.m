//
//  BbLoadBang.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbLoadBang.h"

@implementation BbLoadBang
- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"loadbang";
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleLoadBangNotification:)
                                                name:kLoadBangNotification
                                              object:nil];
}

- (void)loadBang
{
    [self.mainOutlet output:[BbBang bang]];
}

- (void)parentPatchFinishedLoading
{
    [self.mainOutlet output:[BbBang bang]];
}

- (void)handleLoadBangNotification:(NSNotification *)notification
{
    [self loadBang];
}

- (BbInlet *)makeLeftInlet
{
    return nil;
}

- (BbInlet *)makeRightInlet
{
    return nil;
}

@end
