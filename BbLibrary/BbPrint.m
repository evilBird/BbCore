//
//  BbPrint.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbPrint.h"

@implementation BbPrint

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hotInlet = YES;
    [self addChildObject:hotInlet];
    BbInlet *coldInlet = [[BbInlet alloc]init];
    [self addChildObject:coldInlet];
    __weak BbPrint *weakself = self;
    [hotInlet setOutputBlock:^( id value ){
        if ( [value isKindOfClass:[BbBang class]] ) {
            [weakself printBang];
        }else{
            [weakself printValue:value];
        }
    }];
}

+ (NSString *)symbolAlias
{
    return @"p";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"print";
    NSString *text = arguments;
    if (text) {
        self.text = [NSString stringWithString:text];
    }else{
        self.text = @"print";
    }
}

- (void)printBang
{
	NSString *text = _text;
	NSString *value = [NSString stringWithFormat:@"\n%@: bang\n",text];
    [self printValue:value];
}

- (void)printValue:(id)value
{
	NSString *myText = _text;
     if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
         id toPrint = [value mutableCopy];
         NSString *text = [NSString stringWithFormat:@"bB %@: %@",myText,toPrint];
         [[NSNotificationCenter defaultCenter]postNotificationName:kPrintNotificationChannel object:text];
         NSLog(@"%@",text);
     }else{
         NSString *text = [NSString stringWithFormat:@"bB %@: %@",myText,value];
         [[NSNotificationCenter defaultCenter]postNotificationName:kPrintNotificationChannel object:text];
         NSLog(@"%@",text);
     }
}

@end
