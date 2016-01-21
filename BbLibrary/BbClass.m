//
//  BbClass.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/15/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbClass.h"

@interface BbClass ()

@property (nonatomic,strong)        NSString        *className;

@end

@implementation BbClass

- (void)setupPorts
{
    [super setupPorts];
    
    BbInlet *selectorInlet = self.inlets[0];
    BbInlet *classNameInlet = self.inlets[1];
    classNameInlet.hot = YES;
    __block BbOutlet *mainOutlet = self.outlets[0];
    [selectorInlet setInputBlock:[BbPort allowTypesInputBlock:@[[NSString class],[NSArray class]]]];
    [classNameInlet setInputBlock:[BbPort allowTypesInputBlock:@[[NSString class],[NSArray class]]]];
    
    __weak BbClass *weakself = self;
    [selectorInlet setOutputBlock:^ (id value ){
        if ( nil != weakself.className ){
            NSString *selector = nil;
            NSArray *args = nil;
            if ( [value isKindOfClass:[NSString class]] ) {
                selector = value;
            }else if ([ value isKindOfClass:[NSArray class]]){
                selector = [BbHelpers getSelectorFromArray:value];
                args = [BbHelpers getArgumentsFromArray:value];
            }
            mainOutlet.inputElement = [NSInvocation doClassMethod:weakself.className selector:selector arguments:args];
        }
    }];
    
    [classNameInlet setOutputBlock:^ (id value ){
        if ( [value isKindOfClass:[NSString class]] ) {
            weakself.className = value;
            [weakself setObjectArguments:value];
        }else if ([value isKindOfClass:[NSArray class]] ){
            id first = [(NSArray *)value firstObject];
            if ( [first isKindOfClass:[NSString class]] ) {
                weakself.className = first;
                [weakself setObjectArguments:first];
            }
        }
    }];
}

+ (NSString *)symbolAlias
{
    return @"*c";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"Class";
    self.className = arguments;
}

@end
