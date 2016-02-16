//
//  BbIsa.m
//  Pods
//
//  Created by Travis Henspeter on 2/11/16.
//
//

#import "BbIsa.h"
#import "BbRuntimeLookup.h"

@interface BbIsa ()

@property (nonatomic,strong)        NSString        *myClassName;

@end

@implementation BbIsa

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *hotInlet = self.inlets.firstObject;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    
    __block BbOutlet *trueOutlet = self.outlets.firstObject;
    __block BbOutlet *falseOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:falseOutlet];
    
    __weak BbIsa *weakself = self;
    [coldInlet setOutputBlock:^( id value ){
        NSString *text = nil;
        if ([value isKindOfClass:[NSString class]]) {
            text = value;
        }else if ([value isKindOfClass:[NSArray class]]){
            NSArray *arr = value;
            if (arr.count) {
                id first = arr.firstObject;
                if ([first isKindOfClass:[NSString class]]) {
                    text = first;
                }
            }
        }
        
        if (!text) {
            return;
        }
        
        NSString *newClassName = [BbIsa classNameMatchingText:text];
        
        if (!newClassName) {
            return;
        }
        
        [weakself setMyClassName:newClassName];
        
    }];
    
    __block id inputValue;
    
    [hotInlet setOutputBlock:^( id value ){
        inputValue = value;
        if (!weakself.myClassName) {
            [falseOutlet setInputElement:inputValue];
        }
        
        Class myClass = NSClassFromString(weakself.myClassName);
        if ([value isKindOfClass:myClass]) {
            [trueOutlet setInputElement:inputValue];
        }else{
            [falseOutlet setInputElement:inputValue];
        }
    }];
    
}

+ (NSString *)classNameMatchingText:(NSString *)text
{
    NSArray *allClasses = [BbRuntimeLookup getClassNames];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",text];
    NSArray *matchingClasses = [allClasses filteredArrayUsingPredicate:pred];
    if (matchingClasses.count) {
        return matchingClasses.firstObject;
    }
    return nil;
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"isa";
    if (!arguments) {
        self.displayText = self.name;
        return;
    }else{
        self.displayText = [NSString stringWithFormat:@"isa %@",arguments];
    }
    
    NSString *myClassName = nil;
    myClassName = [BbIsa classNameMatchingText:arguments];
    
    if (myClassName) {
        [self setMyClassName:myClassName];
    }
}

- (void)setMyClassName:(NSString *)myClassName
{
    _myClassName = myClassName;
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,myClassName];
    self.creationArguments = myClassName;
}

+ (NSString *)symbolAlias
{
    return @"isa";
}

@end
