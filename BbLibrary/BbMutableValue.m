//
//  BbMutableValue.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/4/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbMutableValue.h"
#import "NSValue+Array.h"

@interface BbMutableValue ()

@property (nonatomic,strong)    NSValue     *myValue;

@end

@implementation BbMutableValue

- (void)setupPorts
{
    [super setupPorts];
    
    __block BbOutlet *memberOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:memberOutlet];
    
    BbInlet *hotInlet = self.inlets.firstObject;
    __block id hotValue;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    __block NSValue *coldValue;
    __block NSArray *memberArray;
    __block BbOutlet *mainOutlet = self.outlets.firstObject;
    
    __weak BbMutableValue *weakself = self;
    [coldInlet setOutputBlock:^(id value){
        if ([value isKindOfClass:[NSValue class]]) {
            coldValue = value;
            weakself.myValue = value;
        }
    }];
    
    [hotInlet setOutputBlock:^(id value){
        if (!value || !coldValue) {
            return;
        }
        if ( [value isKindOfClass:[BbBang class]] ) {
            [mainOutlet setInputElement:coldValue];
            return;
        }
        
        if ( ![value isKindOfClass:[NSArray class]] || [(NSArray *)value count] < 2 ) {
            return;
        }
        
        NSString *selector = nil;
        NSNumber *index = nil;
        NSNumber *newElement = nil;
        
        NSMutableArray *valueCopy = [(NSArray *)value mutableCopy];
        selector = ( [valueCopy[0] isKindOfClass:[NSString class]] ) ? ([(NSString *)valueCopy.firstObject lowercaseString]) : nil;
        [valueCopy removeObjectAtIndex:0];
        index = ( [valueCopy[0] isKindOfClass:[NSNumber class]] ) ? valueCopy.firstObject : nil;
        [valueCopy removeObjectAtIndex:0];
        
        if (valueCopy.count) {
            newElement = ( [valueCopy[0] isKindOfClass:[NSNumber class]]) ? valueCopy.firstObject : nil;
        }
        
        NSArray *valueArray = [coldValue valueArray];
        if ( !index || index.unsignedIntegerValue >= valueArray.count ) {
            return;
        }
        
        if ( [selector isEqualToString:@"get"] ) {
            memberArray = [NSArray arrayWithObjects:index,valueArray[index.unsignedIntegerValue], nil];
            [memberOutlet setInputElement:memberArray];
        }else if ( [selector isEqualToString:@"set"] && newElement ){
            NSMutableArray *valueArrayCopy = valueArray.mutableCopy;
            [valueArrayCopy replaceObjectAtIndex:index.unsignedIntegerValue withObject:newElement];
            NSValue *newValue = [NSValue valueWithArray:valueArrayCopy objCType:coldValue.objCType];
            coldValue = newValue;
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"m val";
    if (arguments) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
    }else{
        self.displayText = self.name;
    }
}

+ (NSString *)symbolAlias
{
    return @"mval";
}



@end
