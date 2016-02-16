//
//  BbSpigot.m
//  Pods
//
//  Created by Travis Henspeter on 2/15/16.
//
//

#import "BbSpigot.h"

@interface BbSpigot ()

@property (nonatomic,strong)    NSNumber    *rightInletValue;

@end

@implementation BbSpigot

+ (NSString *)symbolAlias
{
    return @"spig";
}

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *leftInlet = self.inlets.firstObject;
    BbInlet *rightInlet = self.inlets.lastObject;
    __block BbOutlet *mainOutlet = self.outlets.firstObject;
    __weak BbSpigot *weakself = self;
    [rightInlet setInputBlock:^(id value){
        id outputValue = nil;
        if ([value isKindOfClass:[NSArray class]]) {
            if ([[value firstObject]isKindOfClass:[NSNumber class]]) {
                outputValue = [value firstObject];
            }else if ([[value firstObject]isKindOfClass:[NSString class]]){
                outputValue = [NSNumber numberWithInteger:[(NSString *)[value firstObject]integerValue]];
            }
        }else if ([value isKindOfClass:[NSString class]]){
            outputValue = [NSNumber numberWithInteger:[(NSString *)value integerValue]];
        }else if ([value isKindOfClass:[NSNumber class]]){
            outputValue = value;
        }
        return outputValue;
    }];
    [rightInlet setOutputBlock:^(id value){
        if (value) {
            weakself.rightInletValue = value;
        }
    }];
    [leftInlet setOutputBlock:^(id value){
        NSUInteger rightInletIntegerValue = [weakself.rightInletValue integerValue];
        if (rightInletIntegerValue > 0) {
            [mainOutlet setInputElement:value];
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"spigot";
    if (arguments) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
        self.rightInletValue = [arguments getArgumentAtIndex:0];
    }else{
        self.displayText = self.name;
        self.rightInletValue = @0;
    }
}

@end
