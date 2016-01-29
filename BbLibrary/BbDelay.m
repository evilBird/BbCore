//
//  BbDelay.m
//  Pods
//
//  Created by Travis Henspeter on 1/28/16.
//
//

#import "BbDelay.h"

@interface BbDelay ()

@property (nonatomic)    NSNumber       *interval;

@end

@implementation BbDelay

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *hotInlet = self.inlets.firstObject;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    __block NSTimer *delayTimer;
    __weak BbDelay *weakself = self;
    
    [hotInlet setOutputBlock:^(id value){
        if ( delayTimer.isValid || nil == value ) {
            return;
        }
        NSInvocation *invocation = [NSInvocation invocationForInstance:weakself selector:@"delayedSendValue:" arguments:@[value]];
        delayTimer = [NSTimer scheduledTimerWithTimeInterval:weakself.interval.doubleValue invocation:invocation repeats:NO];
        
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
    if ( arguments ) {
        NSArray *args = [arguments getArguments];
        if ( [args.firstObject isKindOfClass:[NSNumber class]]) {
            self.interval = args.firstObject;
            self.displayText = [NSString stringWithFormat:@"del %@",self.interval];
        }else{
            self.interval = @(1);
            self.displayText = @"del";
        }
    }else{
        self.interval = @(1);
        self.displayText = @"del";
    }
    
    
}

+ (NSString *)symbolAlias
{
    return @"del";
}

- (void)delayedSendValue:(id)value
{
    [self.outlets[0] setInputElement:value];
}

@end
