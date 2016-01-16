//
//  BbInstanceMethod.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/15/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbMethod.h"

@implementation BbMethod

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *targetInlet = self.inlets[0];
    BbInlet *argsInlet = self.inlets[1];
    [argsInlet setInputBlock:[BbPort allowTypeInputBlock:[NSArray class]]];
    __block BbOutlet *mainOutlet = self.outlets[0];
    [targetInlet setOutputBlock:^(id value){
        NSArray *args = argsInlet.outputElement;
        NSString *selector = [BbHelpers getSelectorFromArray:args];
        NSArray *selectorArgs = [BbHelpers getArgumentsFromArray:args];
        mainOutlet.outputElement = [NSInvocation doInstanceMethod:value selector:selector arguments:selectorArgs];
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"Method";
}

@end
