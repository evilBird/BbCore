//
//  BbListElement.m
//  Pods
//
//  Created by Travis Henspeter on 4/2/17.
//
//

#import "BbListElement.h"

@implementation BbListElement

- (void)setupPorts{
    [super setupPorts];
    __block NSArray* cold = nil;
    [self.inlets[0] setInputBlock:[BbPort allowTypeInputBlock:[NSNumber class]]];
    [self.inlets[1] setInputBlock:(id)^(id value){
        cold = value;
        return nil;
    }];
    [self.inlets[0] setOutputBlock:^(id value){
        NSNumber* hot = value;
        if (!hot || !cold || hot.integerValue >= cold.count){
            return;
        }
        
        [self.outlets[0] setInputElement:[cold objectAtIndex:hot.unsignedIntegerValue]];
    }];
}

+ (NSString*)symbolAlias{
    return @"list element";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [[self class]symbolAlias];
    self.displayText = self.name;
}

@end
