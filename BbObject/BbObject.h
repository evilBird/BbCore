//
//  BbObject.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbInlet.h"
#import "BbOutlet.h"
#import "BbRuntime.h"
#import "BbBang.h"
#import "BbCoreProtocols.h"
#import "BbCoreUtils.h"

static   NSString    *kLoadBangNotification          =       @"com.birdSound.bb.core.loadBang";
static   NSString    *kCloseBangNotification         =       @"com.birdSound.bb.core.closeBang";
static   NSString    *kBbSendObjectNotification      =       @"com.birdSound.bb.core.send";
static   NSString    *kBbReceiveObjectNotification   =       @"com.birdSound.bb.core.receive";

@class BbObjectDescription;
@class BbConnectionDescription;

@interface BbObject : NSObject

@property (nonatomic,weak)                  id <BbEntity,BbObject>                          parent;
@property (nonatomic,strong)                id <BbEntityView,BbObjectView>                  view;
@property (nonatomic,weak)                  id <BbObjectDataSource>                         dataSource;

@property (nonatomic,strong)                NSMutableArray                                  *inlets;
@property (nonatomic,strong)                NSMutableArray                                  *outlets;

@property (nonatomic,strong)                NSString                                        *uniqueID;
@property (nonatomic,strong)                NSString                                        *displayText;
@property (nonatomic,strong)                NSString                                        *creationArguments;
@property (nonatomic,strong)                NSString                                        *viewArguments;

@property (nonatomic,strong)                NSString                                        *userText;
@property (nonatomic,strong)                NSHashTable                                     *entityObservers;
@property (nonatomic,strong)                NSString                                        *name;


- (instancetype)initWithArguments:(NSString *)arguments;

- (void)commonInit;

- (void)setupPorts;

- (void)setupWithArguments:(id)arguments;

- (void)cleanup;

+ (NSString *)viewClass;

+ (NSString *)symbolAlias;

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description dataSource:(id<BbObjectDataSource>)dataSource;

@end

@interface BbObject (BbEntityProtocol) <BbEntity>

- (NSArray *)getArgumentsFromText:(NSString *)text;

- (BOOL)addEntityObserver:(id<BbEntity>)entity;

- (BOOL)removeEntityObserver:(id<BbEntity>)entity;

- (BOOL)startObservingEntity:(id<BbEntity>)entity;

- (BOOL)stopObservingEntity:(id<BbEntity>)entity;

- (BOOL)removeAllEntityObservers;

- (BOOL)isChildOfEntity:(id<BbEntity>)entity;

- (NSUInteger)indexInParentEntity;

- (BOOL)isParentOfEntity:(id<BbEntity>)entity;

- (BOOL)addChildEntity:(id<BbEntity>)entity;

- (BOOL)insertChildEntity:(id<BbEntity>)entity atIndex:(NSUInteger)index;

- (BOOL)removeChildEntity:(id<BbEntity>)entity;

- (NSUInteger)indexOfChildEntity:(id<BbEntity>)entity;

- (NSString *)textDescription;

- (NSString *)textDescriptionToken;

- (NSString *)depthStringForChild:(id<BbEntity>)entity;

- (NSSet *)childConnections;

@end

@interface BbObject (BbObjectProtocol) <BbObject>

- (BOOL)canEdit;

- (BOOL)canOpen;

- (id<BbObjectView>)loadView;

- (void)unloadView;

- (NSArray *)loadChildViews;

- (void)unloadChildViews;

- (BOOL)objectView:(id<BbObjectView>)sender didChangeValue:(NSValue *)value forViewArgumentKey:(NSString *)key;

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)sender;

- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender;

- (void)objectView:(id<BbObjectView>)sender didBeginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)editingDelegate;

@end

@interface BbObject (BbObjectEditingDelegate)

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText;

@end

