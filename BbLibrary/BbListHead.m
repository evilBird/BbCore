//
//  BbAtom.m
//  Pods
//
//  Created by Travis Henspeter on 4/2/17.
//
//

#import "BbListHead.h"

@implementation BbListHead

- (void)setupPorts
{
    BbInlet *inlet = [[BbInlet alloc] init];
    inlet.hot = YES;
    [self addChildEntity:inlet];
    BbOutlet *outlet = [[BbOutlet alloc] init];
    [self addChildEntity:outlet];
    [self.inlets[0]setInputBlock:[BbPort allowTypeInputBlock:[NSArray class]]];
    [self.inlets[0]setOutputBlock:^( id value ){
        NSArray *hot = value;
        if (nil == hot || !hot.count) return;
        [self.outlets.firstObject setInputElement:hot.firstObject];
    }];
}

+ (NSString *)symbolAlias
{
    return @"list head";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [[self class]symbolAlias];
    self.displayText = self.name;
}

@end
