//
//  BbSplitArray.m
//  Pods
//
//  Created by Travis Henspeter on 8/8/16.
//
//

#import "BbListSplit.h"

@implementation BbListSplit

- (void)setupPorts
{
    [super setupPorts];
    __block BbOutlet *rightOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:rightOutlet];
    [self.inlets[0]setInputBlock:[BbPort allowTypeInputBlock:[NSArray class]]];
    [self.inlets[1]setInputBlock:[BbPort allowTypeInputBlock:[NSNumber class]]];

    [self.inlets[0]setOutputBlock:^( id value ){
        NSNumber *cold = [self.inlets[1] outputElement];
        NSArray *hot = value;
        if (nil == hot || nil == cold || cold.integerValue >= hot.count) return;
        NSMutableArray *left = [hot subarrayWithRange:NSMakeRange(0, cold.integerValue)].mutableCopy;
        NSMutableArray *right = [hot subarrayWithRange:NSMakeRange(cold.integerValue, hot.count - cold.integerValue)].mutableCopy;
        [self.outlets[1] setInputElement:right];
        [self.outlets[0] setInputElement:left];
    }];
}

+ (NSString *)symbolAlias
{
    return @"list split";
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [[self class]symbolAlias];
    NSArray *args = [(NSString *)arguments getArguments];
    if ( nil != args ) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
        [self.inlets[1]setOutputElement:args.firstObject];
    }
    
}

@end
