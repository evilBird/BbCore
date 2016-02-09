//
//  BbRegexRoute.m
//  Pods
//
//  Created by Travis Henspeter on 2/8/16.
//
//

#import "BbRegexRoute.h"

@interface BbRegexRoute ()

@property (nonatomic,strong)        NSMapTable      *routingTable;

@end

@implementation BbRegexRoute


+ (BOOL)string:(NSString *)aString matchesPattern:(NSString *)pattern
{
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
    NSArray *matches = [regex matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
    return (matches.count > 0);
}

+ (NSString *)matchPattern:(NSString *)pattern inString:(NSString *)string
{
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if ( nil == matches || matches.count == 0 ) {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        [results addObject:[string substringWithRange:wordRange]];
    }
    
    return [results componentsJoinedByString:@" "];
}

- (void)setupPorts {}

+ (NSString *)symbolAlias
{
    return @"regr";
}

- (NSArray *)matchPatterns:(NSArray *)patterns forKey:(NSString *)aKey
{
    NSMutableArray *matches = [NSMutableArray array];
    for (NSString *aPattern in patterns) {
        if ([BbRegexRoute string:aKey matchesPattern:aPattern]) {
            [matches addObject:aPattern];
        }
    }
    
    return matches;
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"RegexRoute";
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
    
    NSString *argString = arguments;
    NSArray *routeArgs = [argString getArguments];
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    self.routingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
    
    for (id anArg in routeArgs ) {
        BbOutlet *anOutlet = [[BbOutlet alloc]init];
        [self addChildEntity:anOutlet];
        [self.routingTable setObject:anOutlet forKey:anArg];
    }
    
    BbOutlet *anOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:anOutlet];
    NSDictionary *routeTableDictionary = [self.routingTable dictionaryRepresentation];
    NSSet *routeKeysSet = [NSSet setWithArray:routeTableDictionary.allKeys];
    NSArray *myPatterns = routeKeysSet.allObjects;
    
    __weak BbRegexRoute *weakself = self;
    
    [hotInlet setOutputBlock:^( id value ){
        if ( [value isKindOfClass:[NSArray class]] ) {
            NSArray *arr = value;
            id key = arr.firstObject;
            NSArray *matches = [weakself matchPatterns:myPatterns forKey:key];
            
            if ( !matches.count) {
                [weakself.outlets.lastObject setInputElement:value];
            }else{
                
                id output = nil;
                if ( arr.count == 1 ) {
                    output = [BbBang bang];
                }else{
                    NSRange rangeToKeep;
                    rangeToKeep.location = 1;
                    rangeToKeep.length = arr.count-1;
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:rangeToKeep];
                    output = [arr objectsAtIndexes:indexSet];
                }
                
                for (NSString *aMatch in matches) {
                    [[weakself.routingTable objectForKey:aMatch]setInputElement:output];
                }
                
            }
        }
    }];
    
}

@end
