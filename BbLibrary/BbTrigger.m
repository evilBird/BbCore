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
    NSEnumerator *outletEnumerator = self.outlets.reverseObjectEnumerator;
    [hotInlet setOutputBlock:^(id value){
        hotValue = value;
        NSUInteger count = arguments.count;
        NSEnumerator *argEnumerator = arguments.reverseObjectEnumerator;
        while ( count -- ) {
            BbOutlet *outlet = [outletEnumerator nextObject];
            NSString *arg = [argEnumerator nextObject];
            if ( [arg isEqualToString:@"b"] ) {
                outlet.inputElement = [BbBang bang];
            }else{
                outlet.inputElement = hotValue;
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
