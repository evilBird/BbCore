//
//  BbPort.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbBridge.h"

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

@interface BbPort : NSObject <BbObject>

@property   (nonatomic,weak)                id<BbObjectParent>                  parent;
@property   (nonatomic,strong)              BbPortInputBlock                    inputBlock;
@property   (nonatomic,strong)              BbPortOutputBlock                   outputBlock;
@property   (nonatomic,weak)                id                                  inputElement;
@property   (nonatomic,weak)                id                                  outputElement;
@property   (nonatomic)                     BbPortScope                         scope;
@property   (nonatomic,strong)              id<BbObjectView>                    view;
@property   (nonatomic,strong)              NSString                            *uniqueID;
@property   (nonatomic,strong)              NSHashTable                         *observers;
@property   (nonatomic,strong)              NSHashTable                         *observedPorts;

- (void)commonInit;

- (BOOL)connectToPort:(BbPort *)port;

- (BOOL)disconnectFromPort:(BbPort *)port;

#pragma mark - <BbObject>

- (BOOL)startObservingObject:(id<BbObject>)object;

- (BOOL)stopObservingObject:(id<BbObject>)object;

- (BOOL)addObjectObserver:(id<BbObject>)object;

- (BOOL)removeObjectObserver:(id<BbObject>)object;

- (BOOL)removeAllObjectObservers;

@end

@interface BbPort (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;

@end

@interface BbPort (Meta)

+ (BbPortInputBlock)passThroughInputBlock;
+ (BbPortInputBlock)allowTypeInputBlock:(Class)type;
+ (BbPortInputBlock)allowTypesInputBlock:(NSArray *)types;

@end