//
//  BbExpression.m
//  Pods
//
//  Created by Travis Henspeter on 2/14/16.
//
//

#import "BbExpression.h"

@interface BbExpression ()

@property (nonatomic,strong)    NSString    *formatString;
@property (nonatomic,strong)    id          rightHandValue;

@property (nonatomic,strong)    NSString    *leftHandSymbol;
@property (nonatomic,strong)    NSString    *operatorSymbol;
@property (nonatomic,strong)    NSString    *rightHandSymbol;


@end

@implementation BbExpression

+ (NSString *)symbolAlias
{
    return @"expr";
}

- (void)setupPorts
{
    [super setupPorts];
    __block BbOutlet *mainOutlet = self.outlets.firstObject;
    
    BbInlet *leftInlet = self.inlets.firstObject;
    BbInlet *rightInlet = self.inlets.lastObject;
    rightInlet.hot = YES;
    
    __block BbOutlet *falseOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:falseOutlet];
    
    __weak BbExpression *weakself = self;
    [rightInlet setInputBlock:^( id value ){
        id outputValue = value;
        if ([value isKindOfClass:[NSArray class]]) {
            outputValue = [value firstObject];
        }
        return outputValue;
    }];
    
    [rightInlet setOutputBlock:^(id value){
        weakself.rightHandValue = value;
    }];
    
    [leftInlet setInputBlock:^(id value){
        id outputValue = value;
        if ([value isKindOfClass:[NSArray class]]) {
            outputValue = [value firstObject];
        }
        
        return outputValue;
    }];
    
    [leftInlet setOutputBlock:^(id value){
        if (!weakself.formatString) {
            return;
        }
        
        if (value && weakself.formatString) {
            NSString *myFormatString = [NSString stringWithString:weakself.formatString];
            NSPredicate *myPredicate = [NSPredicate predicateWithFormat:myFormatString];
            NSMutableDictionary *substitutionVars = [NSMutableDictionary dictionary];
            if (weakself.leftHandSymbol) {
                NSString *key = [weakself.leftHandSymbol substringFromIndex:1];
                [substitutionVars setObject:value forKey:key];
            }
            if (weakself.rightHandSymbol && weakself.rightHandValue) {
                NSString *key = [weakself.rightHandSymbol substringFromIndex:1];
                [substitutionVars setObject:weakself.rightHandValue forKey:key];
            }
            NSUInteger result = [myPredicate evaluateWithObject:value substitutionVariables:substitutionVars];
            if (result) {
                [mainOutlet setInputElement:value];
            }else{
                [falseOutlet setInputElement:value];
            }
        }
    }];
}


- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    [self setupWithArguments:creationArguments];
}

- (void)getSymbolsFromText:(NSString *)text
{
    NSArray *args = [[text trimWhitespace]getArguments];
    __weak BbExpression *weakself = self;
    NSAssert(args.count >= 3, @"ERROR NEED AT LEAST THREE ARGS");
    __block id rightHandFormatStringArg = nil;
    [args enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"$"]) {
            switch (idx) {
                case 2:
                {
                    weakself.rightHandSymbol = obj;
                    rightHandFormatStringArg = obj;
                }
                    break;
                    
                default:
                    weakself.leftHandSymbol = obj;
                    break;
            }
        }else if ([obj isKindOfClass:[NSString class]]&&idx==1){
            weakself.operatorSymbol = obj;
        }else if (([obj isKindOfClass:[NSString class]]||[obj isKindOfClass:[NSNumber class]])&&idx == 2){
            weakself.rightHandSymbol = nil;
            weakself.rightHandValue = obj;
            rightHandFormatStringArg = obj;
        }
    }];
    
    NSString *formatString = [NSString stringWithFormat:@"%@ %@ %@",weakself.leftHandSymbol,weakself.operatorSymbol,rightHandFormatStringArg];
    weakself.displayText = formatString;
    weakself.formatString = formatString;
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"expr";
    if (arguments) {
        self.displayText = [NSString stringWithFormat:@"%@",arguments];
        [self getSymbolsFromText:arguments];
    }else{
        self.displayText = self.name;
    }
    
}



@end
