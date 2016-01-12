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

@end