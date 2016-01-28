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

@end

@implementation BbInstance

- (void)setupPorts
{
    BbInlet *selectorInlet = [[BbInlet alloc]init];
    selectorInlet.hot = YES;
    [self addChildEntity:selectorInlet];
    
    BbInlet *instanceInlet = [[BbInlet alloc]init];
    instanceInlet.hot = YES;
    [self addChildEntity:instanceInlet];
    
    __block BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
    
    __weak BbInstance *weakself = self;
    
    [selectorInlet setOutputBlock:^ (id value ){
        
        if ( [value isKindOfClass:[BbBang class]] ) {
            
            NSMutableArray *outputArray = [NSMutableArray array];
            [outputArray addObject:kSELF];
            [outputArray addObject:_myInstance];
            mainOutlet.inputElement = outputArray;
            
        }else if ( nil != weakself.myInstance ){
            
            NSString *selector = [BbHelpers getSelectorFromArray:value];
            NSArray *args = [BbHelpers getArgumentsFromArray:value];
            id output = [NSInvocation doInstanceMethod:weakself.myInstance selector:selector arguments:args];
            
            if ( nil != output ) {
                
                NSMutableArray *outputArray = [NSMutableArray array];
                [outputArray addObject:selector];
                [outputArray addObject:output];
                mainOutlet.inputElement = outputArray;
            }
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

+ (NSString *)symbolAlias
{
    return @"*i";
}

- (void)setupWithArguments:(id)arguments
{
    if ( nil != arguments ) {
        self.displayText = [NSString stringWithFormat:@"*%@",arguments];
    }else{
        self.displayText = @"*instance";
    }
    
    self.name = @"*i";
    
}


@end
