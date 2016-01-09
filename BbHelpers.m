//
//  BbHelpers.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbHelpers.h"
#import <UIKit/UIKit.h>

@implementation BbHelpers

+ (NSString *)createUniqueIDString
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

+ (NSArray *)string2Array:(NSString *)string
{
    if ( nil == string ) {
        return nil;
    }
    NSArray *components = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *temp = [NSMutableArray array];
    for (NSString *aComponent in components ) {
        id argument = [BbHelpers stringComponent2Object:aComponent];
        if ( nil != argument ) {
            [temp addObject:argument];
        }
    }
    
    if ( temp.count ) {
        return [NSArray arrayWithArray:temp];
    }
    
    return nil;
}

+ (id)stringComponent2Object:(NSString *)string
{
    if ( nil == string ) {
        return nil;
    }
    
    NSString *trimmed = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( trimmed.length == 0 ) {
        return nil;
    }
    
    NSCharacterSet *decimalDigits = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSRange range = [trimmed rangeOfCharacterFromSet:decimalDigits options:0];
    if ( range.location == NSNotFound || range.length < trimmed.length ) {
        return trimmed; //Return as string
    }
    
    double doubleValue = [trimmed doubleValue];
    return @(doubleValue);

}

+ (NSString *)position2String:(id)position
{
    if ( nil == position ) {
        return @"0 0";
    }
    
    if ( [position isKindOfClass:[NSValue class] ]) {
        CGPoint point = [(NSValue *)position CGPointValue];
        CGFloat x = point.x;
        CGFloat y = point.y;
        return [NSString stringWithFormat:@"%.2f %.2f",x,y];
    }

    return @"0 0";
}

@end
