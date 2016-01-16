//
//  BbParseText.h
//  Pods
//
//  Created by Travis Henspeter on 1/10/16.
//
//

#import <Foundation/Foundation.h>
#import "BbTextDescription.h"

@interface BbParseText : NSObject

+ (BbPatchDescription *)parseText:(NSString *)text;
- (instancetype)initWithText:(NSString *)text;
- (BbPatchDescription *) parse;

+ (NSUInteger)countOccurencesOfSubstring:(NSString *)substring
                         beforeSubstring:(NSString *)endString
                                inString:(NSString *)string;

+ (NSString *)connectionArgumentsFromString:(NSString *)string;
+ (NSString *)objectArgumentsFromString:(NSString *)string;
+ (NSString *)parentViewArgumentsFromString:(NSString *)string;
+ (NSString *)childViewArgumentsFromString:(NSString *)string;

@end
