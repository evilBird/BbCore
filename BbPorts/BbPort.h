//
//  BbPort.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbCoreProtocols.h"

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

@property   (nonatomic,weak)                id<BbEntity,BbObject>               parent;
@property   (nonatomic,strong)              BbPortInputBlock                    inputBlock;
@property   (nonatomic,strong)              BbPortOutputBlock                   outputBlock;
@property   (nonatomic,weak)                id                                  inputElement;
@property   (nonatomic,weak)                id                                  outputElement;
@property   (nonatomic)                     BbPortScope                         scope;
@property   (nonatomic,strong)              id<BbEntityView>                    view;
@property   (nonatomic,strong)              NSString                            *uniqueID;
@property   (nonatomic,strong)              NSHashTable                         *entityObservers;

- (void)commonInit;

- (BOOL)connectToPort:(BbPort *)port;

- (BOOL)disconnectFromPort:(BbPort *)port;


@end

@interface BbPort (BbEntityProtocol) <BbEntity>

+ (NSString *)viewClass;

- (id<BbEntityView>)loadView;

- (void)unloadView;

- (BOOL)addEntityObserver:(id<BbEntity>)entity;

- (BOOL)removeEntityObserver:(id<BbEntity>)entity;

- (BOOL)startObservingEntity:(id<BbEntity>)entity;

- (BOOL)stopObservingEntity:(id<BbEntity>)entity;

- (BOOL)removeAllEntityObservers;

- (BOOL)isChildOfEntity:(id<BbEntity>)entity;

- (NSUInteger)indexInParentEntity;

@end

@interface BbPort (Meta)

+ (BbPortInputBlock)passThroughInputBlock;
+ (BbPortInputBlock)allowTypeInputBlock:(Class)type;
+ (BbPortInputBlock)allowTypesInputBlock:(NSArray *)types;

@end