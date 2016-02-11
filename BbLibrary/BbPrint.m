//
//  BbPrint.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbPrint.h"

@interface BbPrint ()

@property (nonatomic,strong)    UIColor         *textColorAttribute;

@end


@implementation BbPrint

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    BbInlet *coldInlet = [[BbInlet alloc]init];
    [self addChildEntity:coldInlet];
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

- (void)setTextColorAttributeWithArgs:(NSString *)args
{
    NSArray *argArray = [[args trimWhitespace]getArguments];
    UIColor *defaultColor = [UIColor blackColor];
    if (argArray.count < 3) {
        self.textColorAttribute = defaultColor;
        self.displayText = [NSString stringWithFormat:@"print %@",args];
        self.text = args;
        return;
    }
    
    NSRange rangeToInspect;
    rangeToInspect.length = 3;
    rangeToInspect.location = argArray.count-3;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:rangeToInspect];
    NSArray *lastThreeElements = [argArray objectsAtIndexes:indexSet];
    BOOL elementsAreValid = YES;
    CGFloat myComponents[3];
    NSUInteger i = 0;
    for (id anElement in lastThreeElements) {
        if (![anElement isKindOfClass:[NSNumber class]]) {
            elementsAreValid = NO;
            break;
        }else{
            myComponents[i] = [(NSNumber *)anElement doubleValue];
        }
        
        i++;
    }
    
    if (!elementsAreValid) {
        self.textColorAttribute = defaultColor;
        self.displayText = [NSString stringWithFormat:@"print %@",args];
        self.text = args;
        return;
    }else{
        NSRange rangeToKeep;
        rangeToKeep.location = 0;
        rangeToKeep.length = (argArray.count-3);
        NSIndexSet *indicesToKeep = [NSIndexSet indexSetWithIndexesInRange:rangeToKeep];
        NSArray *argsToDisplay = [argArray objectsAtIndexes:indicesToKeep];
        NSString *argText = @"";
        
        if (argsToDisplay.count) {
            argText = [argsToDisplay componentsJoinedByString:@" "];
            self.displayText = [NSString stringWithFormat:@"print %@",argText];
            self.text = argText;
        }else{
            self.displayText = @"print";
            self.text = @"print";
        }
        
        self.textColorAttribute = [UIColor colorWithRed:myComponents[0] green:myComponents[1] blue:myComponents[2] alpha:1.0];
    }
    
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"print";
    NSString *text = arguments;
    [self setTextColorAttributeWithArgs:text];
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
    NSDictionary *myAttributes = @{NSForegroundColorAttributeName:self.textColorAttribute};
    
     if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
         id toPrint = [value mutableCopy];
         NSString *text = [NSString stringWithFormat:@"bB %@: %@\n",myText,toPrint];
         NSDictionary *myObject = @{@"text":text,
                                    @"attributes":myAttributes};
         [[NSNotificationCenter defaultCenter]postNotificationName:kPrintNotificationChannel object:myObject];
         NSLog(@"%@",text);
     }else{
         NSString *text = [NSString stringWithFormat:@"bB %@: %@\n",myText,value];
         NSDictionary *myObject = @{@"text":text,
                                    @"attributes":myAttributes};
         [[NSNotificationCenter defaultCenter]postNotificationName:kPrintNotificationChannel object:myObject];
         NSLog(@"%@",text);
     }
}

@end
