//
//  BbAdd.m
//  BbLang
//
//  Created by Travis Henspeter on 7/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbAdd.h"

@implementation BbAdd

- (void)setupPorts
{
    [super setupPorts];
    [self.inlets[0]setInputBlock:[BbPort allowTypeInputBlock:[NSNumber class]]];
    [self.inlets[1]setInputBlock:[BbPort allowTypeInputBlock:[NSNumber class]]];
    __weak BbAdd *weakself = self;
    [self.inlets[0]setOutputBlock:^( id value ){
        NSNumber *cold = [weakself.inlets[1] outputElement];
        NSNumber *hot = value;
        NSNumber *result = @( hot.doubleValue + cold.doubleValue );
        [weakself.outlets[0] setInputElement:result];
    }];
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

+ (NSString *)symbolAlias
{
    return @"+";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [[self class] symbolAlias];
    NSArray *args = [(NSString *)arguments getArguments];
    if ( nil != args ) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
        [self.inlets[1]setOutputElement:args.firstObject];
    }
}

@end
