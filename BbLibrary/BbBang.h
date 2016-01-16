//
//  BbBang.h
//  BbPatchExample
//
//  Created by Travis Henspeter on 7/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BbBang : NSObject

+ (BbBang *)bang;

@property (nonatomic,readonly)  NSDate          *timeStamp;
@property (nonatomic,strong)    NSString        *uniqueID;

@end
