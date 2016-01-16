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
#import "BbHelpers.h"
#import "BbBridge.h"
#import "BbBang.h"

@class BbObjectDescription;
@class BbConnectionDescription;

@interface BbObject : NSObject

@property (nonatomic,weak)                  id <BbObjectParent>                     parent;
@property (nonatomic,strong)                NSString                                *uniqueID;

@property (nonatomic,strong)                NSString                                *objectArguments;

@property (nonatomic,strong)                NSString                                *viewClass;
@property (nonatomic,strong)                NSString                                *viewArguments;

@property (nonatomic,strong)                NSMutableArray                          *inlets;
@property (nonatomic,strong)                NSMutableArray                          *outlets;

@property (nonatomic,strong)                id<BbObjectView>                         view;

@property (nonatomic,strong)                NSHashTable                             *observers;
@property (nonatomic,strong)                NSString                                *name;

@property (nonatomic)                       NSUInteger                              myDepth;

- (instancetype)initWithArguments:(NSString *)arguments;

- (void)commonInit;

- (void)setupPorts;

- (void)setupWithArguments:(id)arguments;

+ (NSString *)viewClass;

@end

@interface BbObject (BbObject)

- (BOOL)addObjectObserver:(id<BbObject>)object;

- (BOOL)removeObjectObserver:(id<BbObject>)object;

- (BOOL)removeAllObjectObservers;

- (void)loadBang;

@end

@interface BbObject (BbObjectChild) <BbObjectChild>

- (BOOL)loadView;

- (NSUInteger)indexInParent;

- (NSString *)textDescription;

- (NSString *)descriptionToken;

@end

@interface BbObject (BbObjectParent)<BbObjectParent>

- (BOOL)isParentObject:(id<BbObjectChild>)child;

- (BOOL)addChildObject:(id<BbObjectChild>)child;

- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index;

- (BOOL)removeChildObject:(id<BbObjectChild>)child;

- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child;

@end

@interface BbObject (BbObjectViewDataSource) <BbObjectViewDataSource>

- (NSUInteger)numberOfInletsForObjectView:(id<BbObjectView>)objectView;

- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView;

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView;

@end

@interface BbObject (BbObjectViewDelegate) <BbObjectViewDelegate>

- (void)objectView:(id<BbObjectView>)sender didChangePosition:(NSValue *)position;

@end
