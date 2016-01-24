//
//  BbParseText.h
//  Pods
//
//  Created by Travis Henspeter on 1/10/16.
//
//

#import <Foundation/Foundation.h>
#import "BbTextDescription.h"

static NSString *kCopiedObjectDescriptionsKey = @"objectDescriptions";
static NSString *kCopiedConnectionDescriptionsKey = @"connectionDescriptions";

@interface BbParseText : NSObject

+ (BbPatchDescription *)parseText:(NSString *)text;
- (instancetype)initWithText:(NSString *)text;
- (BbPatchDescription *) parse;

+ (NSDictionary *)parseCopiedText:(NSString *)text;     //Assumes that there is no parent entity for objects and connections. Returns a dictionary with two keys: objectDescriptions, and connectionDescriptions

+ (NSUInteger)countOccurencesOfSubstring:(NSString *)substring
                         beforeSubstring:(NSString *)endString
                                inString:(NSString *)string;

+ (NSString *)connectionArgumentsFromString:(NSString *)string;
+ (NSString *)objectArgumentsFromString:(NSString *)string;
+ (NSString *)parentViewArgumentsFromString:(NSString *)string;
+ (NSString *)childViewArgumentsFromString:(NSString *)string;

@end
