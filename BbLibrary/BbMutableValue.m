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

- (void)setupWithArguments:(id)arguments
{
    self.name = @"Mutable value";
    self.myValue = nil;
    self.memberOutlet = [[BbOutlet alloc]init];
    self.memberOutlet.name = @"members";
    [self addPort:self.memberOutlet];
}

- (void)inletReceievedBang:(BbInlet *)inlet
{
    if ( inlet == self.hotInlet ) {
        NSValue *myValue = (NSValue *)self.coldInlet.value;
        [self.mainOutlet output:myValue];
    }
}

- (void)hotInlet:(BbInlet *)inlet receivedValue:(id)value
{
    if ( inlet == self.hotInlet ) {
        
        if ( [value isKindOfClass:[BbBang class]]) {
            return;
        }
        
        NSValue *myValue = (NSValue *)self.coldInlet.value;
        
        if ( nil == myValue ) {
            return;
        }
        
        NSArray *valueArray = [myValue valueArray];
        
        if ( [value isKindOfClass:[NSString class]] && [value isEqualToString:@"get"]) {
            [self.memberOutlet output:valueArray];
            return;
        }
        
        if ( [value isKindOfClass:[NSArray class]]) {
            NSMutableArray *valCopy = [(NSArray *)value mutableCopy];
            NSString *selector = valCopy.firstObject;
            [valCopy removeObjectAtIndex:0];
            NSNumber *index = valCopy.firstObject;
            [valCopy removeObjectAtIndex:0];
            
            if ( [selector isEqualToString:@"get"] ) {
                
                if ( index.unsignedIntegerValue < valueArray.count ) {
                    [self.memberOutlet output:@[valueArray[index.unsignedIntegerValue]]];
                }
                
            }else if ( [selector isEqualToString:@"set"] && valCopy.count > 0 ){
                if ( index.unsignedIntegerValue < valueArray.count ) {
                    NSMutableArray *valueArrayCopy = valueArray.mutableCopy;
                    [valueArrayCopy replaceObjectAtIndex:index.unsignedIntegerValue withObject:valCopy.firstObject];
                    NSValue *newValue = [myValue valueWithArray:valueArrayCopy];
                    self.coldInlet.value = newValue;
                }
            }
        }
        
    }
    
}

- (void)calculateOutput
{
    
}

@end
