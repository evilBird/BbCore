//
//  BbMetro.m
//  Pods
//
//  Created by Travis Henspeter on 1/28/16.
//
//

#import "BbMetro.h"

@interface BbMetro ()

@property (nonatomic,strong)        NSNumber        *interval;
@property (nonatomic,strong)        NSNumber        *state;

@end

@implementation BbMetro

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *hotInlet = self.inlets.firstObject;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    __block NSTimer *metroTimer;
    __weak BbMetro *weakself = self;
    
    [hotInlet setInputBlock:^(id value){
        NSNumber *newState = nil;
        if ( [value isKindOfClass:[NSNumber class]] ) {
            newState = value;
        }else if ( [value isKindOfClass:[NSArray class]] && [[(NSArray *)value firstObject]isKindOfClass:[NSNumber class]]){
            newState = [(NSArray *)value firstObject];
        }
        return newState;
    }];
    
    [hotInlet setOutputBlock:^(id value){
        if ( value && value != weakself.state ) {
            weakself.state = value;
            if (weakself.state.integerValue) {
                NSInvocation *invocation = [NSInvocation invocationForInstance:weakself selector:@"metroSendBang" arguments:@[[BbBang bang]]];
                metroTimer = [NSTimer scheduledTimerWithTimeInterval:weakself.interval.doubleValue invocation:invocation repeats:YES];
            }else{
                [metroTimer invalidate];
            }
        }
    }];
    
    [coldInlet setInputBlock:^(id value){
        NSNumber *newInterval = nil;
        if ( [value isKindOfClass:[NSNumber class]] ) {
            newInterval = value;
        }else if ( [value isKindOfClass:[NSArray class]] && [[(NSArray *)value firstObject]isKindOfClass:[NSNumber class]]){
            newInterval = [(NSArray *)value firstObject];
        }
        return newInterval;
    }];
    
    [coldInlet setOutputBlock:^(id value){
        if ( value ) {
            weakself.interval = value;
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"metro";
    if (arguments) {
        NSArray *args = [arguments getArguments];
        if ( [args.firstObject isKindOfClass:[NSNumber class]]) {
            self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,args.firstObject];
            self.interval = args.firstObject;
        }else{
            self.displayText = self.name;
            self.interval = @(1);
        }
    }else{
        self.displayText = self.name;
        self.interval = @(1);
    }
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

- (void)metroSendBang
{
    
}

+ (NSString *)symbolAlias
{
    return @"metro";
}

@end
