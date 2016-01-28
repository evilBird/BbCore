//
//  BbDelegate.m
//  Pods
//
//  Created by Travis Henspeter on 1/23/16.
//
//

#import "BbProxy.h"
#import "BbRuntime.h"

@interface BbProxy () <BbRuntimeProtocolAdopterProxy>

@property (nonatomic,strong)        BbRuntimeProtocolAdopter        *delegateInstance;
@property (nonatomic,strong)        NSHashTable                     *clientTable;
@property (nonatomic,strong)        NSMapTable                      *returnValueTable;
@end

@implementation BbProxy

- (void)setupPorts
{
    BbInlet *clientInlet = [[BbInlet alloc]init];
    clientInlet.hot = YES;
    [self addChildEntity:clientInlet];
    
    __weak BbProxy *weakself = self;
    [clientInlet setOutputBlock:^( id value ){
        if ( [value isKindOfClass:[NSArray class]] && [(NSArray*)value count] == 3 ) {
            NSString *selector = [(NSArray*)value objectAtIndex:0];
            if ( [[selector lowercaseString] isEqualToString:@"setClient:property:"] ) {
        
                id client = [(NSArray*)value objectAtIndex:1];
                NSString *property = [(NSArray*)value objectAtIndex:2];
                [weakself setClient:client property:property];
                
            }
        }
    }];
    
    BbInlet *returnInlet = [[BbInlet alloc]init];
    returnInlet.hot = YES;
    [self addChildEntity:returnInlet];
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
    [returnInlet setOutputBlock:^( id value ){
        if ([value isKindOfClass:[NSArray class]] && [(NSArray*)value count] > 1 ) {
            NSString *selector = [(NSArray*)value firstObject];
            NSMutableArray *valueCopy = [(NSArray*)value mutableCopy];
            [valueCopy removeObjectAtIndex:0];
            NSArray *returnVal = [NSArray arrayWithArray:valueCopy];
            [weakself.returnValueTable setObject:returnVal forKey:selector];
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    if ( nil == arguments ) {
        self.displayText = @"proxy";
    }else{
        self.displayText = arguments;
    }
}

- (void)setClient:(id)client property:(NSString *)property
{
    NSAssert(nil!=client, @"ERROR: CLIENT INSTANCE IS NIL");
    if ( nil == property ) {
        return;
    }
    
    if ( nil != self.clientTable && [self.clientTable containsObject:client] ) {
        return;
    }
    
    self.displayText = property;
    self.creationArguments = property;
    [self.view setTitleText:self.displayText];
    
    self.delegateInstance = nil;
    self.returnValueTable = nil;
    self.clientTable = nil;
    
    
    self.clientTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [self.clientTable addObject:client];
    self.returnValueTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    self.delegateInstance  = [[BbRuntimeProtocolAdopter alloc]initWithClientClass:NSStringFromClass([client class])
                                                                   clientProperty:property
                                                                            proxy:self];
    [client setObject:self forKey:property];
}

- (void)setupProxyForProperty:(NSString *)property withClient:(id)client
{
    NSAssert(nil!=client, @"ERROR: CLIENT INSTANCE IS NIL");
    if ( nil == property ) {
        return;
    }
    
    if ( nil != self.clientTable && [self.clientTable containsObject:client] ) {
        return;
    }
    
    self.displayText = property;
    self.creationArguments = property;
    [self.view setTitleText:self.displayText];
    
    self.delegateInstance = nil;
    self.returnValueTable = nil;
    self.clientTable = nil;
    
    
    self.clientTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [self.clientTable addObject:client];
    self.returnValueTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
    self.delegateInstance  = [[BbRuntimeProtocolAdopter alloc]initWithClientClass:NSStringFromClass([client class])
                                                                   clientProperty:property
                                                                            proxy:self];
    [client setObject:self forKey:property];
}

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
    NSArray *returnValueKeys = [self.returnValueTable dictionaryRepresentation].allKeys;
    NSSet *returnValueSet = [NSSet setWithArray:returnValueKeys];
    
    if ( [returnValueSet containsObject:selectorName] ) {
        return [self.returnValueTable valueForKey:selectorName];
    }
    
    return nil;
}

+ (NSString *)symbolAlias
{
    return @"proxy";
}


@end
