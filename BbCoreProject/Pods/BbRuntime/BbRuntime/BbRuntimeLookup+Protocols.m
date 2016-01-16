//
//  BbRuntime+Protocol.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeLookup.h"

@implementation BbRuntimeLookup (Protocols)

+ (NSArray *)getProtocolNames
{
    return [BbRuntimeLookup getProtocolNamesIncludePrivate:NO];
}

+ (NSArray *)getProtocolNamesIncludePrivate:(BOOL)includePrivate
{
    unsigned int count;
    __unsafe_unretained id *protocols = objc_copyProtocolList(&count);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    for ( int i = 0; i < count; i ++ ) {
        Protocol *p = protocols[i];
        NSString *protocolName = [NSString stringWithUTF8String:protocol_getName(p)];
        if ( includePrivate ) {
            [result addObject:protocolName];
        }else{
            if ( ![protocolName hasPrefix:@"_"] ) {
                [result addObject:protocolName];
            }
        }
    }
    
    free(protocols);
    
    return [NSArray arrayWithArray:[result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}

+ (NSString *)getProtocolForObjectProperty:(NSString *)propertyName class:(NSString *)className
{
    NSString *attributes = [BbRuntimeLookup getAttributesForProperty:propertyName ofClass:className];
    NSRange startCharRange = [attributes rangeOfString:@"<"];
    NSRange endCharRange = [attributes rangeOfString:@">"];
    NSRange protocolNameRange;
    protocolNameRange.location = startCharRange.location+1;
    protocolNameRange.length = ((endCharRange.location)-protocolNameRange.location);
    NSString *protocolName = [attributes substringWithRange:protocolNameRange];
    return protocolName;
}

+ (NSDictionary *)getMethodSignaturesForProtocol:(NSString *)protocolName
{
    unsigned int count;
    Protocol *p = NSProtocolFromString(protocolName);
    struct objc_method_description *descs = protocol_copyMethodDescriptionList(p, NO, YES, &count);
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (NSUInteger i = 0; i < count; i ++ ) {
        struct objc_method_description desc = descs[i];
        if ( NULL != desc.name && NULL != desc.types ) {
            NSString *name = NSStringFromSelector(desc.name);
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:desc.types];
            results[name] = methodSignature;
        }
    }
    free(descs);
    descs = protocol_copyMethodDescriptionList(p, YES, YES, &count);
    
    for (NSUInteger i = 0; i < count; i ++ ) {
        struct objc_method_description desc = descs[i];
        if ( NULL != desc.name && NULL != desc.types ) {
            NSString *name = NSStringFromSelector(desc.name);
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:desc.types];
            results[name] = methodSignature;
        }
    }
    free(descs);
    
    return results;
}

@end
