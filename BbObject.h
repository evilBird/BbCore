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
#import "BbConnection.h"
#import "BbRuntime.h"
#import "BbHelpers.h"
#import "BbBridge.h"

@class BbObjectDescription;
@class BbConnectionDescription;

@interface BbObject : NSObject

@property (nonatomic,weak)                  id <BbObjectParent>                     parent;
@property (nonatomic,strong)                NSString                                *uniqueID;

@property (nonatomic,strong)                NSString                                *objectClass;
@property (nonatomic,strong)                NSString                                *objectArguments;

@property (nonatomic,strong)                NSString                                *viewClass;
@property (nonatomic,strong)                NSString                                *viewArguments;

@property (nonatomic,strong)                NSMutableArray                          *myInlets;
@property (nonatomic,strong)                NSMutableArray                          *myOutlets;
@property (nonatomic,strong)                NSMutableArray                          *myChildren;
@property (nonatomic,strong)                NSMutableArray                          *myConnections;

@property (nonatomic,strong)                id<BbObjectView>                         view;

@property (nonatomic,strong)                NSHashTable                             *observers;
@property (nonatomic,readonly)              NSString                                *textDescription;
@property (nonatomic)                       NSUInteger                              myDepth;


- (instancetype)initWithArguments:(NSString *)arguments;
- (void)setupWithArguments:(id)arguments;
- (void)setupPorts;
- (NSString *)myToken;

#pragma mark - BbObject protocol

- (BOOL)addObjectObserver:(id<BbObject>)object;
- (BOOL)removeObjectObserver:(id<BbObject>)object;
- (BOOL)removeAllObjectObservers;

@end

@interface BbObject (BbObjectParent) <BbObjectParent>

- (BOOL)isParentObject:(id<BbObjectChild>)child;
- (BOOL)addChildObject:(id<BbObjectChild>)child;
- (BOOL)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index;
- (BOOL)removeChildObject:(id<BbObjectChild>)child;
- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child;
- (NSString *)depthStringForChildObject:(id<BbObjectChild>)child;

@end

@interface BbObject (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;

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

@interface BbObject (Ports)

- (void)setupDefaultPorts;
- (void)didAddChildPort:(BbPort *)childPort;
- (void)didRemoveChildPort:(BbPort *)childPort;

@end

@interface BbObject (Connections)

- (void)didAddChildConnection:(BbConnection *)connection;
- (void)didRemoveChildConnection:(BbConnection *)connection;

@end

@interface BbObject (Meta)

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description;
- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description;
- (BOOL)loadView;

@end