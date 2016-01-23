//
//  BbCoreUtils.m
//  Pods
//
//  Created by Travis Henspeter on 1/19/16.
//
//

#import "BbCoreUtils.h"

@implementation BbCoreUtils

@end

@implementation NSString (BbCoreUtils)

+ (NSString *)uniqueIDString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = NULL;
    if (uuid) {
        uuidString = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    
    NSString *uniqueIDString = (__bridge_transfer NSString *)uuidString;
    return uniqueIDString;
}

- (NSString *)trimWhitespace
{
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceCharacterSet];
    return [self stringByTrimmingCharactersInSet:whiteSpace];
}

- (NSArray *)getComponents
{
    NSString *trimmed = [self trimWhitespace];
    NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceCharacterSet];
    return [trimmed componentsSeparatedByCharactersInSet:whiteSpace];
}

- (NSArray *)getArguments
{
    if ( self.length == 0 ) {
        return [NSArray array];
    }
    NSArray *components = [self getComponents];
    NSCharacterSet *digitsCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789.-+"];
    NSCharacterSet *nonDigitsCharSet = [digitsCharSet invertedSet];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:components.count];
    for (NSString *aComponent in components ) {
        NSString *trimmedComponent = [aComponent trimWhitespace];
        if ( [trimmedComponent rangeOfCharacterFromSet:nonDigitsCharSet].length > 0 ) {
            [result addObject:trimmedComponent];
        }else if ( [trimmedComponent rangeOfString:@"."].length > 0 ){
            [result addObject:@([trimmedComponent doubleValue])];
        }else{
            [result addObject:@([trimmedComponent integerValue])];
        }
    }
    
    return [NSArray arrayWithArray:result];
}

- (NSUInteger)numberOfArguments
{
    NSArray *arguments = [self getArguments];
    return arguments.count;
}

- (id)getArgumentAtIndex:(NSUInteger)index
{
    NSArray *arguments = [self getArguments];
    
    if ( index >= arguments.count ) {
        return nil;
    }
    return arguments[index];
}

- (NSString *)setArgument:(id)argument atIndex:(NSUInteger)index
{
    NSArray *arguments = [self getArguments];
    
    if ( index > arguments.count || nil == argument ) {
        return nil;
    }
    
    NSMutableArray *argumentsCopy = arguments.mutableCopy;
    if ( index < argumentsCopy.count ) {
        argumentsCopy[index] = argument;
    }else if ( index == argumentsCopy.count ){
        [argumentsCopy addObject:argument];
    }
    
    NSString *argumentsString = [argumentsCopy getString];
    
    return [argumentsString trimWhitespace];
}

@end


@implementation NSArray (BbCoreUtils)

- (NSString *)getString
{
    return [self componentsJoinedByString:@" "];
}

@end