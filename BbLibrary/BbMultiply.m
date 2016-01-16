//
//  BbMultiply.m
//  BbLang
//
//  Created by Travis Henspeter on 7/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbMultiply.h"

@implementation BbMultiply

- (void)setupPorts
{
    [super setupPorts];
    [self.inlets[0]setInputBlock:[BbPort allowTypeInputBlock:[NSNumber class]]];
    [self.inlets[1]setInputBlock:[BbPort allowTypeInputBlock:[NSNumber class]]];
    __weak BbMultiply *weakself = self;
    [self.inlets[0]setOutputBlock:^( id value ){
        NSNumber *cold = [weakself.inlets[1] outputElement];
        NSNumber *hot = value;
        NSNumber *result = @( hot.doubleValue * cold.doubleValue );
        [weakself.outlets[0] setInputElement:result];
    }];
}

+ (NSString *)symbolAlias
{
    return @"*";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [[self class]symbolAlias];
    NSArray *args = [BbHelpers string2DoubleArray:arguments];
    if ( nil != args ) {
        [self.inlets[1]setOutputElement:args.firstObject];
    }
}

@end
