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
    __block id returnVal = nil;
    __weak BbClass *weakself = self;
    
    [selectorInlet setInputBlock:^(id value){
        return value;
    }];
    
    [selectorInlet setOutputBlock:^ (id value ){
        
        if (![value isKindOfClass:[NSString class]] && ![value isKindOfClass:[NSArray class]] ) {
            //NSAssert(1==3, @"INPUT ERROR IN PORT");
            return;
        }
        
        if ( nil != weakself.className ){
            NSString *selector = nil;
            NSArray *args = nil;
            
            if ( [value isKindOfClass:[NSString class]] ) {
                selector = value;
            }else if ([ value isKindOfClass:[NSArray class]]){
                selector = [BbHelpers getSelectorFromArray:value];
                args = [BbHelpers getArgumentsFromArray:value];
            }
            returnVal = [NSInvocation doClassMethod:weakself.className selector:selector arguments:args];
            mainOutlet.inputElement = returnVal;
        }
    }];
    
    [classNameInlet setOutputBlock:^ (id value ){
        if ( [value isKindOfClass:[NSString class]] ) {
            weakself.className = value;
            [weakself setCreationArguments:value];
        }else if ([value isKindOfClass:[NSArray class]] ){
            id first = [(NSArray *)value firstObject];
            if ( [first isKindOfClass:[NSString class]] ) {
                weakself.className = first;
                [weakself setCreationArguments:first];
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
    [self.inlets[1]setInputElement:self.className];
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
}

@end
