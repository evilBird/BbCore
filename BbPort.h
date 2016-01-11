//
//  BbPort.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbObjectParent.h"
#import "BbConnection.h"

typedef NS_ENUM(NSUInteger, BbPortScope) {
    BbPortScope_Output,
    BbPortScope_Input
};

typedef id  (^BbPortBlock)     (id value);

static NSString *kOutputElement =   @"outputElement";
static NSString *kInputElement  =   @"inputElement";

@interface BbPort : NSObject    <BbConnectionDelegate,BbObjectChild>

@property   (nonatomic,weak)                BbObject<BbObjectParent>            *parent;
@property   (nonatomic,strong)              BbPortBlock                         inputBlock;
@property   (nonatomic,strong)              BbPortBlock                         outputBlock;
@property   (nonatomic,weak)                id                                  inputElement;
@property   (nonatomic,weak)                id                                  outputElement;
@property   (nonatomic)                     BbPortScope                         scope;
@property   (nonatomic,strong)              id<BbObjectView>                    view;
@property   (nonatomic,strong)              NSString                            *uniqueID;
@property   (nonatomic,readonly)            NSArray                             *connections;
@property   (nonatomic,strong)              NSMutableSet                        *myConnections;

- (id)getValue;
- (void)commonInit;
+ (BbPortBlock)passThruPortBlock;

@end

@interface BbInlet : BbPort

@property   (nonatomic,getter=isHotInlet)   BOOL                              hotInlet;
@property   (nonatomic)                     NSString                          *targetOutletID;

@end

@interface BbOutlet : BbPort

@end

