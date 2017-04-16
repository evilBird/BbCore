//
//  BbListEnumerate.m
//  Pods
//
//  Created by Travis Henspeter on 4/2/17.
//
//

#import "BbListEnumerate.h"

@implementation BbListEnumerate

- (void)setupPorts{
    [super setupPorts];
    [self addChildEntity:[[BbOutlet alloc] init]];
    __block NSArray* cold = nil;
    [self.inlets[0] setInputBlock:[BbPort allowTypeInputBlock:[BbBang class]]];
    [self.inlets[1] setInputBlock:(id)^(id value){
        cold = value;
        return nil;
    }];

    [self.inlets[0] setOutputBlock:^(id value){
        
        if (!cold.count){
            [self.outlets[1] setInputElement:[BbBang bang]];
            return;
        }
        NSMutableArray* newCold = cold.mutableCopy;
        id output = newCold.firstObject;
        [newCold removeObjectAtIndex:0];
        cold = newCold;
        [self.outlets[0] setInputElement:output];
    }];
    
}

+ (NSString*)symbolAlias{
    return @"list enum";
}

- (void)setupWithArguments:(id)arguments{
    [super setupWithArguments:arguments];
    self.name = [[self class] symbolAlias];
    self.displayText = self.name;
}

@end
