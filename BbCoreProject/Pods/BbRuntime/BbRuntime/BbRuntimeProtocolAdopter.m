//
//  BbDynamicProtocolAdopter.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeProtocolAdopter.h"
#import "BbRuntimeImpBlock.h"
#import "BbRuntimeLookup.h"
#import "NSInvocation+BbRuntime.h"
#import "NSObject+BbRuntime.h"

@interface BbRuntimeProtocolAdopter ()

@property (nonatomic,strong) NSString               *clientClassName;
@property (nonatomic,strong) NSString               *clientPropertyName;
@property (nonatomic,strong) NSSet                  *availableProtocols;
@property (nonatomic,strong) NSMutableSet           *availableSelectors;
@property (nonatomic,strong) NSMutableDictionary    *adoptedProtocols;
@property (nonatomic,strong) id                     disposableObject;

@end

@implementation BbRuntimeProtocolAdopter

- (instancetype)initWithClientClass:(NSString *)className clientProperty:(NSString *)propertyName proxy:(id<BbRuntimeProtocolAdopterProxy>)proxyObject
{
    self = [super init];
    if ( self ) {
        _clientClassName = className;
        _clientPropertyName = propertyName;
        _proxyObject = proxyObject;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    NSArray *protocolNames = [BbRuntimeLookup getProtocolNames];
    if ( nil != protocolNames ){
        self.availableProtocols = [NSSet setWithArray:protocolNames];
    }

    self.adoptedProtocols = [NSMutableDictionary dictionary];
    self.availableSelectors = [NSMutableSet set];
    
    if ( nil == self.clientClassName || nil == self.clientPropertyName ){
        return;
    }
    
    [self adoptProtocolsForObjectProperty:self.clientPropertyName class:self.clientClassName];
}

- (void)adoptProtocolsForObjectProperty:(NSString *)propertyName class:(NSString *)className
{
    NSString *protocolName = [BbRuntimeLookup getProtocolForObjectProperty:propertyName class:className];
    if ( nil == protocolName || ![self.availableProtocols containsObject:protocolName] || [self adoptsProtocol:protocolName] ) {
        return;
    }
    
    NSDictionary *protocolSigs = [BbRuntimeLookup getMethodSignaturesForProtocol:protocolName];
    if ( nil == protocolSigs ) {
        return;
    }
    
    [self.availableSelectors addObjectsFromArray:protocolSigs.allKeys];
    self.adoptedProtocols[protocolName] = protocolSigs;
    
}

- (BOOL)adoptsProtocol:(NSString *)protocolName
{
    return [self.adoptedProtocols.allKeys containsObject:protocolName];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    NSString *protocolName = NSStringFromProtocol(aProtocol);
    return [self adoptsProtocol:protocolName];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    NSString *selectorName = NSStringFromSelector(aSelector);
    return [self.availableSelectors containsObject:selectorName];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSString *selectorName = NSStringFromSelector(aSelector);
    NSArray *adoptedProtocolNames = self.adoptedProtocols.allKeys;
    NSMethodSignature *result = nil;
    for (NSString *protocolName in adoptedProtocolNames) {
        NSDictionary *methodSigDictionary = self.adoptedProtocols[protocolName];
        NSArray *selectorNames = methodSigDictionary.allKeys;
        if ( [selectorNames containsObject:selectorName] ) {
            result = methodSigDictionary[selectorName];
            break;
        }
    }
    
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL theSelector = anInvocation.selector;
    NSString *selectorName = NSStringFromSelector(theSelector);
    NSString *returnType = [NSString stringWithUTF8String:[anInvocation.methodSignature methodReturnType]];
    NSArray *arguments = [anInvocation getArgumentObjects];
    NSString *typeString = [anInvocation getTypeString];
    self.disposableObject = nil;
    id returnVal = [self.proxyObject protocolAdopter:self forwardsSelector:selectorName withArguments:arguments expectsReturnType:returnType];
    id impBlock = [BbRuntimeImpBlock impBlockWithReturnValue:returnVal type:returnType];
    self.disposableObject = [NSObject uniqueClassInstance];
    [self.disposableObject addMethodForSelector:theSelector types:typeString.UTF8String block:impBlock];
    [anInvocation invokeWithTarget:self.disposableObject];
}


@end
