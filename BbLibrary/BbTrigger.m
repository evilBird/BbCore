//
//  BbTrigger.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/15/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbTrigger.h"

@interface BbTrigger ()

@end

@implementation BbTrigger

- (void)setupPorts {}

- (void)setupPortsWithArguments:(NSArray *)arguments
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    for ( NSUInteger i = 0 ; i < arguments.count; i ++ ) {
        BbOutlet *outlet = [[BbOutlet alloc]init];
        [self addChildEntity:outlet];
    }
    __block id hotValue;
    __block id outputValue;
    //NSEnumerator *outletEnumerator = self.outlets.reverseObjectEnumerator;
    NSArray *myArguments = arguments;
    
    __weak BbTrigger *weakself = self;
    
    [hotInlet setOutputBlock:^(id value){
        hotValue = value;
        NSUInteger count = myArguments.count;
        for (NSInteger i = (count-1); i >= 0; --i) {
            BbOutlet *outlet = weakself.outlets[i];
            NSString *arg = myArguments[i];
            if ( [arg isEqualToString:@"b"] ) {
                outputValue = [BbBang bang];
                outlet.inputElement = outputValue;
            }else{
                outputValue = hotValue;
                outlet.inputElement = outputValue;
            }
        }
    }];
}

+ (NSString *)symbolAlias
{
    return @"t";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = [[self class]symbolAlias];
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
    NSArray *toTrigger = [arguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self setupPortsWithArguments:toTrigger];
}

@end
