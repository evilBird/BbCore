//
//  BbBangObject.m
//  Pods
//
//  Created by Travis Henspeter on 1/28/16.
//
//

#import "BbBangObject.h"

@implementation BbBangObject

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    __block BbOutlet *outlet = [[BbOutlet alloc]init];
    [self addChildEntity:outlet];
    
    [hotInlet setOutputBlock:^(id value){
        outlet.inputElement = [BbBang bang];
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.displayText = nil;
}

+ (NSString *)symbolAlias
{
    return @"b";
}

+ (NSString *)viewClass
{
    return @"BbBangView";
}

@end
