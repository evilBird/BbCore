//
//  BbBang.m
//  BbPatchExample
//
//  Created by Travis Henspeter on 7/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbBang.h"
#import "BbCoreProtocols.h"

@implementation BbBang

+ (BbBang *)bang
{
    return [[BbBang alloc]init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeStamp = [NSDate date];
        _uniqueID = [NSString uniqueIDString];
    }
    
    return self;
}


@end
