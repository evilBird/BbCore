//
//  NSValue+Array.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/4/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "NSValue+Array.h"

@implementation NSValue (Array)

- (NSUInteger)getMemberCount
{
    NSString *typeString = [NSString stringWithUTF8String:self.objCType];
    NSScanner *scanner = [NSScanner scannerWithString:typeString];
    NSCharacterSet *typeEncodingSet = [NSCharacterSet characterSetWithCharactersInString:@"d"];
    NSCharacterSet *toSkipSet = [typeEncodingSet invertedSet];
    scanner.charactersToBeSkipped = toSkipSet;
    BOOL done = NO;
    NSUInteger result = 0;
    while (!done) {
        NSString *scanString = [NSString new];
        BOOL didScan = [scanner scanCharactersFromSet:typeEncodingSet intoString:&scanString];
        NSUInteger count = ( didScan ) ? ( scanString.length ) : ( 0 );
        result+=count;
        done = ( scanner.isAtEnd ) ? ( YES ) : ( NO );
    }
    
    return result;
}

- (NSArray *)valueArray
{
    NSUInteger memberCount = [self getMemberCount];
    if ( !memberCount ) {
        return nil;
    }
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:memberCount];
    void *buffer = malloc(sizeof(double)*memberCount);
    [self getValue:buffer];
    for (NSUInteger i = 0; i < memberCount; i ++ ) {
        double value = ((double *)buffer)[i];
        [temp addObject:@(value)];
    }
    free(buffer);
    return [NSArray arrayWithArray:temp];
}

- (NSValue *)valueWithArray:(NSArray *)array
{
    NSUInteger memberCount = [self getMemberCount];
    NSAssert(memberCount==array.count, @"NSVALUE: Number of members does not match array length");
    void *buffer = malloc(sizeof(double)*memberCount);
    for (NSInteger i = 0; i < memberCount; i++) {
        double arrayVal = [array[i] doubleValue];
        ((double *)buffer)[i] = arrayVal;
    }
    
    NSValue *result = [NSValue valueWithBytes:buffer objCType:self.objCType];
    free(buffer);
    return result;
}

static void copyArrayToBuffer(void *buffer, NSArray *array)
{
    NSUInteger count = array.count;
    for ( NSUInteger i = 0 ; i < count ; i ++ ) {
        ((double *)buffer)[i] = [array[i] doubleValue];
    }
}

+ (NSValue *)valueWithArray:(NSArray *)array objCType:(const char *)type
{
    NSUInteger count = array.count;
    void *buffer = malloc(sizeof(double) * count + 1);
    copyArrayToBuffer(&buffer, array);
    NSValue *value = [NSValue valueWithBytes:&buffer objCType:type];
    return value;
}


@end
