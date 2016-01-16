//
//  BbRuntime+Properties.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeLookup.h"

@implementation BbRuntimeLookup (Properties)

+ (NSArray *)getPropertyNamesForClass:(NSString *)className
{
    return [BbRuntimeLookup getPropertyNamesForClass:className includePrivate:NO];
}

+ (NSArray *)getPropertyNamesForClass:(NSString *)className includePrivate:(BOOL)includePrivate
{
    unsigned int count;
    Class c = NSClassFromString(className);
    objc_property_t *properties = class_copyPropertyList(c, &count);
    NSMutableArray *propertyNames = [NSMutableArray array];
    for ( int i = 0 ; i < count ; i ++ ) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(properties[i])];
        if ( includePrivate ) {
            [propertyNames addObject:propertyName];
        }else{
            if ( [propertyName hasPrefix:@"_"] == NO ) {
                [propertyNames addObject:propertyName];
            }
        }
    }
    
    free(properties);
    
    return [NSArray arrayWithArray:[propertyNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
}

+ (NSString *)getAttributesForProperty:(NSString *)propertyName ofClass:(NSString *)className
{
    return [BbRuntimeLookup getAttributesForProperty:propertyName ofClass:className includePrivate:NO];
}

+ (NSString *)getAttributesForProperty:(NSString *)propertyName ofClass:(NSString *)className includePrivate:(BOOL)includePrivate
{
    NSString *attributes = nil;
    objc_property_t property = class_getProperty(NSClassFromString(className), propertyName.UTF8String);
    if ( NULL == property ) {
        return nil;
    }
    
    attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
    
    return attributes;
}

+ (objc_property_t)getProperty:(NSString *)propertyName ofClass:(NSString *)className
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(className), &count);
    objc_property_t result = NULL;
    for (NSUInteger i = 0; i < count; i ++ ) {
        objc_property_t p = properties[i];
        const char *pname = property_getName(p);
        NSString *name = [NSString stringWithUTF8String:pname];
        
        NSLog(@"name: %@",name);
        
    }
    
    return result;
}


@end
