//
//  BbProtocol.m
//  Pods
//
//  Created by Travis Henspeter on 2/8/16.
//
//

#import "BbProtocol.h"
#import "BbRuntime.h"

static NSString *kSELF = @"self";
static NSString *kSET = @"set";

@interface BbProtocol () <BbRuntimeProtocolAdopterProxy>

@property (nonatomic,strong)    NSString                            *myProtocolName;
@property (nonatomic,strong)    BbRuntimeProtocolAdopter            *myProtocolAdopter;
@property (nonatomic,strong)    NSMapTable                          *returnValueMapTable;

@end

@implementation BbProtocol

+ (NSString *)symbolAlias
{
    return @"protocol";
}

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    BbInlet *returnInlet = [[BbInlet alloc]init];
    returnInlet.hot = YES;
    [self addChildEntity:returnInlet];
    __block BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
    
    __block NSArray *outputArray;
    
    __weak BbProtocol *weakself = self;
    [hotInlet setOutputBlock:^( id value ){
        
        if ([value isKindOfClass:[BbBang class]] && weakself.myProtocolAdopter ) {
            NSMutableArray *anArray = [NSMutableArray array];
            [anArray addObject:kSELF];
            [anArray addObject:weakself.myProtocolAdopter];
            outputArray = [NSArray arrayWithArray:anArray];
            mainOutlet.inputElement = outputArray;
            return;
        }
        
        NSString *protocolName = nil;
        
        if ([value isKindOfClass:[NSString class]]) {
            protocolName = value;
        }else if ([value isKindOfClass:[NSArray class]]){
            NSArray *inputArray = value;
            if (inputArray.count) {
                id firstObject = inputArray.firstObject;
                if ([firstObject isKindOfClass:[NSString class]]) {
                    protocolName = firstObject;
                }
            }
        }
        
        if (protocolName) {
            
            BOOL success = [weakself adoptProtocolWithName:protocolName];
            NSMutableArray *anArray = [NSMutableArray array];
            [anArray addObject:@"adoptProtocolWithName:"];
            [anArray addObject:protocolName];
            [anArray addObject:@(success)];
            NSArray *statusArray = [NSArray arrayWithArray:anArray];
            mainOutlet.inputElement = statusArray;
        }
        
    }];
    

    [returnInlet setOutputBlock:^( id value ){
        
        if ([value isKindOfClass:[NSArray class]] && [(NSArray*)value count] > 1 ) {
            NSString *selector = [(NSArray*)value firstObject];
            NSMutableArray *valueCopy = [(NSArray*)value mutableCopy];
            [valueCopy removeObjectAtIndex:0];
            NSArray *returnVal = [NSArray arrayWithArray:valueCopy];
            [weakself.returnValueMapTable setObject:returnVal forKey:selector];
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"protocol";
    if (arguments) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
    }else{
        self.displayText = self.name;
    }
}

- (BOOL)adoptProtocolWithName:(NSString *)protocolName
{
    if (!self.myProtocolAdopter) {
        self.myProtocolAdopter = [[BbRuntimeProtocolAdopter alloc]initWithProxy:self];
        self.returnValueMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    }
    
    return [self.myProtocolAdopter adoptProtocolWithName:protocolName];
}

#pragma mark - BbRuntimeProtocolAdopterProxy

- (id)protocolAdopter:(id)sender
     forwardsSelector:(NSString *)selectorName
        withArguments:(NSArray *)arguments
    expectsReturnType:(NSString *)returnType
{
    if ( nil == selectorName ) {
        return nil;
    }
    
    NSMutableArray *toSend = [NSMutableArray array];
    [toSend addObject:selectorName];
    
    if ( nil != arguments ) {
        [toSend addObjectsFromArray:arguments];
    }
    
    [self.outlets.firstObject setInputElement:[NSArray arrayWithArray:toSend]];
    
    if ([returnType isEqualToString:@"v"]) {
        return nil;
    }
    
    NSArray *returnValueKeys = [self.returnValueMapTable dictionaryRepresentation].allKeys;
    NSSet *returnValueSet = [NSSet setWithArray:returnValueKeys];
    
    if ( [returnValueSet containsObject:selectorName] ) {
        return [self.returnValueMapTable valueForKey:selectorName];
    }
    
    return nil;
}

@end
