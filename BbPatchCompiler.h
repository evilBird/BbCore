//
//  BbPatchCompiler.h
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kNewPatchToken                 =       @"#N";
static NSString *kPatchPattern                  =       @"canvas %d %d %d %d %@ %@ %@ ... ;\n";
static NSString *kAbstractionPattern            =       @"abstraction %d %d %@ %@ %@ %@ ... ;\n%@...\nrestore";
static NSString *kNewChildToken                 =       @"#X";
static NSString *kChildObjectPattern            =       @"%d %d %@ %@ ... ;\n"; //position.x, position.y, Object Name, object args
static NSString *kChildObjectToken              =       @"*Box";
static NSString *kChildConnectionToken          =       @"connection";
static NSString *kConnectionPattern             =       @"%d %d %d %d;\n";

@class BbPatch;

@interface BbPatchCompiler : NSObject

- (BbPatch *)compiledPatchFromText:(NSString *)text;

- (NSArray *)scanTokensInText:(NSString *)text;

@end
