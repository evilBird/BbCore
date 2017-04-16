//
//  BbListLength.m
//  Pods
//
//  Created by Travis Henspeter on 4/4/17.
//
//

#import "BbListLength.h"

@implementation BbListLength

- (void)setupPorts{
    BbInlet* inlet = [[BbInlet alloc] init];
    inlet.hot = YES;
    [self addChildEntity:inlet];
    BbOutlet* outlet = [[BbOutlet alloc] init];
    [self addChildEntity:outlet];
    [inlet setInputBlock:[BbPort allowTypeInputBlock:[NSArray class]]];
    [inlet setOutputBlock:^(id value){
        if (value == nil){
            [self.outlets[0] setInputElement:@0];
        }else{
            [self.outlets[0] setInputElement:@([(NSArray*)value count])];
        }
    }];
}

- (void)setupWithArguments:(id)arguments{
    self.name = [[self class] symbolAlias];
    self.displayText = self.name;
}

+ (NSString*)symbolAlias{
    return @"list len";
}

@end
