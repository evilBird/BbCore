//
//  BbPatchCompiler.m
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatchCompiler.h"
#import "NSMutableArray+Stack.h"
#import "BbPatch.h"


@interface BbPatchCompiler ()

@property (nonatomic,strong)    NSMutableArray      *patchStack;

@end

@implementation BbPatchCompiler

- (BbPatch *)compiledPatchFromText:(NSString *)text
{
    self.patchStack = nil;
    BbPatch *result = [BbPatch new];
    
    
    return nil;
}

- (NSArray *)scanTokensInText:(NSString *)text
{
    return nil;
}

@end
