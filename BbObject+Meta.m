//
//  BbObject+Meta.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbRuntime.h"

static NSString *kViewArgsPattern = @"(?#[N|X]) (?:(?!connection)).[a-zA-Z0-9]+ [0-9\.\-]+ [0-9\.\-]+";
static NSString *kObjectArgsPattern = @"(?:(\S+\s\S+\s+[0-9\.\-]\s[0-9\.\-]\s))[a-zA-Z0-9\.\-]+[^;]";

@implementation BbObject (Meta)

+ (NSString *)testDescription
{
    return @"#N BbPatchView 0 0 BbPatch;\n#X BbBoxView 0 0 BbObject object 1;\n#X BbBoxView 0 -200 BbObject object 2;\n#X BbBoxView 0 200 BbObject object 3;\n#X connection 0 0 1 0;\n#X connection 1 0 2 0;\nrestore\n";
}

+ (BbObject *)objectWithTextDescription:(NSString *)text
{
    NSArray *components = [text componentsSeparatedByString:@"\n"];
    
}

+ (NSString *)viewArgsFromText:(NSString *)text
{
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kViewArgsPattern options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        [results addObject:[text substringWithRange:wordRange]];
    }
    
    return [results componentsJoinedByString:@" "];
}

+ (NSString *)objectArgsFromText:(NSString *)text
{
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kObjectArgsPattern options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        [results addObject:[text substringWithRange:wordRange]];
    }
    
    return [results componentsJoinedByString:@" "];
}

+ (BbObject *)createObject:(NSString *)className arguments:(NSString *)arguments
{
    BbObject *object = [NSInvocation doClassMethod:className selector:@"alloc" arguments:nil];
    NSArray *args = ( nil != arguments ) ? ( @[arguments] ) : nil;
    [NSInvocation doInstanceMethod:object selector:@"initWithArguments:" arguments:args];
    return object;
}

+ (id<BbObjectView>)createView:(NSString *)className dataSource:(id<BbObjectViewDataSource>)dataSource
{
    id<BbObjectView> view = nil;
    view = [NSInvocation doClassMethod:className selector:@"alloc" arguments:nil];
    [NSInvocation doInstanceMethod:view selector:@"initWithDataSource:" arguments:@[dataSource]];
    return view;
}

@end


