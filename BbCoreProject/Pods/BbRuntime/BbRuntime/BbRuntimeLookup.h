//
//  BbRuntimeLookup.h
//  BbRuntime
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbRuntimeDefs.h"

@interface BbRuntimeLookup : NSObject

@end

@interface BbRuntimeLookup (Methods)

+ (NSArray *)getMethodNamesForClass:(NSString *)className;

@end

@interface BbRuntimeLookup (Types)

+ (NSString *)encoding2String:(const char *)encoding;
+ (BbType)typeFromEncodingString:(NSString *)string;
+ (NSUInteger)sizeOfArgType:(const char *)encoding;
+ (NSUInteger)sizeOfType:(NSString *)encodingString;

@end

@interface BbRuntimeLookup (Protocols)

+ (NSArray *)getProtocolNames;
+ (NSDictionary *)getMethodSignaturesForProtocol:(NSString *)protocolName;
+ (NSString *)getProtocolForObjectProperty:(NSString *)propertyName class:(NSString *)className;

@end

@interface BbRuntimeLookup (Classes)

+ (NSArray *)getClassNames;

@end

@interface BbRuntimeLookup (Properties)

+ (NSArray *)getPropertyNamesForClass:(NSString *)className;
+ (objc_property_t)getProperty:(NSString *)propertyName ofClass:(NSString *)className;
+ (NSString *)getAttributesForProperty:(NSString *)propertyName ofClass:(NSString *)className;

@end