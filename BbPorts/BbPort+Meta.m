//
//  BbPort+Meta.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPort.h"

@implementation BbPort (Meta)

+ (BbPortInputBlock)passThroughInputBlock
{
    BbPortInputBlock block = ^(id value){
        return value;
    };
    
    return block;
}

+ (BbPortInputBlock)allowTypeInputBlock:(Class)type
{
    BbPortInputBlock block = ^(id value){
        if ( [value isKindOfClass:type] ) {
            return value;
        }else{
            id nilValue = nil;
            return nilValue;
        }
    };
    return block;
}

+ (BbPortInputBlock)allowTypesInputBlock:(NSArray *)types
{
    BbPortInputBlock block = ^(id value){
        NSEnumerator *typeEnum = types.objectEnumerator;
        Class aType = [typeEnum nextObject];
        BOOL OK = [value isKindOfClass:aType];
        while ( !OK && NULL != aType ) {
            aType = [typeEnum nextObject];
            OK = [value isKindOfClass:[typeEnum nextObject]];
        }
        if ( OK ) {
            return value;
        }else{
            id nilValue = nil;
            return nilValue;
        }
    };
    return block;
}

@end