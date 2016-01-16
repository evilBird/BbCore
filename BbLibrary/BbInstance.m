//
//  BbInstance.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/2/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbInstance.h"
#import "BbRuntime.h"

@interface BbInstance ()

@property (nonatomic,strong)        id          myInstance;
@property (nonatomic,strong)        NSString    *className;

@end

@implementation BbInstance

- (void)setupPorts
{
    BbInlet *selectorInlet = [[BbInlet alloc]init];
    selectorInlet.hotInlet = YES;
    [self addChildObject:selectorInlet];
    
    BbInlet *instanceInlet = [[BbInlet alloc]init];
    instanceInlet.hotInlet = YES;
    [self addChildObject:instanceInlet];
    
    __block BbOutlet *selectorOutlet = [[BbOutlet alloc]init];
    [self addChildObject:selectorOutlet];
    
    [selectorInlet setInputBlock:[BbPort allowTypeInputBlock:[NSArray class]]];
    
    __weak BbInstance *weakself = self;
    [selectorInlet setOutputBlock:^ (id value ){
        if ( nil != weakself.myInstance ){
            NSString *selector = [BbHelpers getSelectorFromArray:value];
            NSArray *args = [BbHelpers getArgumentsFromArray:value];
            selectorOutlet.inputElement = [NSInvocation doInstanceMethod:weakself.myInstance selector:selector arguments:args];
        }
    }];
    
    [instanceInlet setOutputBlock:^ (id value ){
        if ( [value isKindOfClass:[BbBang class]] ) {
            weakself.myInstance = nil;
        }else if ( weakself.myInstance != value ){
            weakself.myInstance = nil;
            weakself.myInstance = value;
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"Instance";
    self.className = arguments;
}

- (void)loadBang
{
    if ( nil != self.className ) {
        id anInstance = [NSInvocation doClassMethod:self.className selector:@"new" arguments:nil];
        [self.inlets[1] setInputElement:anInstance];
    }
}

@end
