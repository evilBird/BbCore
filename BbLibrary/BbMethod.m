//
//  BbInstanceMethod.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/15/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbMethod.h"

@interface BbMethod ()

@property (nonatomic,strong)        id  myTarget;

@end

@implementation BbMethod

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *argsInlet = self.inlets[0];
    BbInlet *targetInlet = self.inlets[1];
    targetInlet.hot = YES;
    __block id myTarget = nil;
    [targetInlet setOutputBlock:^(id value){
        myTarget = value;
    }];
    
    [argsInlet setInputBlock:[BbPort allowTypeInputBlock:[NSArray class]]];
    __block BbOutlet *mainOutlet = self.outlets[0];
    __block id outputValue;
    [argsInlet setOutputBlock:^(id value){
        NSArray *args = value;
        NSString *selector = [BbHelpers getSelectorFromArray:args];
        NSArray *selectorArgs = [BbHelpers getArgumentsFromArray:args];
        outputValue = [NSInvocation doInstanceMethod:myTarget selector:selector arguments:selectorArgs];
        [mainOutlet setInputElement:outputValue];
    }];
}

+ (NSString *)symbolAlias
{
    return @"Do";
}

- (void)setupWithArguments:(id)arguments
{
    self.displayText = [[self class] symbolAlias];
}

@end
