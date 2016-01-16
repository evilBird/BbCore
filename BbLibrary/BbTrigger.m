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
    hotInlet.hotInlet = YES;
    [self addChildObject:hotInlet];
    for ( NSUInteger i = 0 ; i < arguments.count; i ++ ) {
        BbOutlet *outlet = [[BbOutlet alloc]init];
        [self addChildObject:outlet];
    }
    
    NSEnumerator *outletEnumerator = self.outlets.reverseObjectEnumerator;
    NSEnumerator *argumentEnumerator = arguments.reverseObjectEnumerator;
    [hotInlet setOutputBlock:^(id value){
        NSUInteger count = arguments.count;
        while ( -- count ) {
            BbOutlet *outlet = [outletEnumerator nextObject];
            NSString *arg = [argumentEnumerator nextObject];
            if ( [arg isEqualToString:@"b"] ) {
                outlet.inputElement = [BbBang bang];
            }else{
                outlet.inputElement = value;
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
    NSArray *toTrigger = [arguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self setupPortsWithArguments:toTrigger];
}

@end
