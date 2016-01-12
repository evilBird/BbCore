//
//  BbPort.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbObjectChild.h"
#import "BbObjectParent.h"
#import "BbConnectionDelegate.h"
#import "BbObjectView.h"
#import "BbObjectViewDataSource.h"

typedef NS_ENUM(NSUInteger, BbPortScope) {
    BbPortScope_Output,
    BbPortScope_Input
};

typedef NS_ENUM(NSUInteger, BbPortElement) {
    BbPortElement_Output,
    BbPortElement_Input
};

typedef id  (^BbPortInputBlock)     (id value);
typedef void (^BbPortOutputBlock)   (id value);

static NSString *kOutputElement =   @"outputElement";
static NSString *kInputElement  =   @"inputElement";

@interface BbPort : NSObject

@property   (nonatomic,weak)                id<BbObjectParent>                  parent;
@property   (nonatomic,strong)              BbPortInputBlock                    inputBlock;
@property   (nonatomic,strong)              BbPortOutputBlock                   outputBlock;
@property   (nonatomic,weak)                id                                  inputElement;
@property   (nonatomic,weak)                id                                  outputElement;
@property   (nonatomic)                     BbPortScope                         scope;
@property   (nonatomic,strong)              id<BbObjectView>                    view;
@property   (nonatomic,strong)              NSString                            *uniqueID;
@property   (nonatomic,strong)              NSHashTable                         *observedPorts;

- (void)commonInit;
- (BOOL)connectToPort:(BbPort *)port;
- (BOOL)disconnectFromPort:(BbPort *)port;
//- (BOOL)connectToElement:(BbPortElement)element ofPort:(BbPort *)portToObserve;
//- (BOOL)disconnectFromElement:(BbPortElement)element ofPort:(BbPort *)portToObserve;

@end

@interface BbPort (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;

@end

@interface BbPort (Meta)

+ (BbPortInputBlock)passThroughInputBlock;

@end