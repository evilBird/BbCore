//
//  BbObject.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbPort.h"

typedef id (^BbCalculateBlock) (id value);

@interface BbObject : NSObject

@property (nonatomic,strong)                NSString                                *titleText;
@property (nonatomic,strong)                NSString                                *arguments;

@property (nonatomic,strong)                NSMutableArray                          *myInlets;
@property (nonatomic,strong)                NSMutableArray                          *myOutlets;
@property (nonatomic,strong)                NSMutableArray                          *myChildren;
@property (nonatomic,strong)                NSMutableArray                          *myConnections;

@property (nonatomic,weak)                  BbObject<BbObjectParent>                *parent;
@property (nonatomic,strong)                id<BbObjectView>                         view;

@property (nonatomic,strong)                NSString                                *viewArguments;
@property (nonatomic,strong)                NSString                                *uniqueID;
@property (nonatomic,readonly)              NSString                                *textDescription;

@property (nonatomic,strong)                NSMutableDictionary                     *calculateBlocks;
@property (nonatomic,strong)                NSMutableDictionary                     *calculateBlockTargets;

- (instancetype)initWithArguments:(NSString *)arguments;
- (void)setupWithArguments:(id)arguments;
- (void)setupPorts;

- (BOOL)addChildObject:(BbObject<BbObjectChild>*)child;
- (BbObject<BbObjectChild>*)removeChildObject:(BbObject<BbObjectChild>*)child;

+ (BbCalculateBlock)passThruCalculateBlock;
- (NSString *)textDescription;
+ (NSString *)myToken;

@end

@interface BbObject (BbObjectParent) <BbObjectParent>

- (NSString *)uniqueID;
- (BOOL)isParentObject:(id<BbObjectChild>)child;
- (void)addChildObject:(id<BbObjectChild>)child;
- (void)insertChildObject:(id<BbObjectChild>)child atIndex:(NSUInteger)index;
- (void)removeChildObject:(id<BbObjectChild>)child;

- (NSUInteger)indexOfChildObject:(id<BbObjectChild>)child;
- (id<BbObjectChild>)childObjectAtIndex:(NSUInteger)index;

@end

@interface BbObject (BbObjectChild) <BbObjectChild>

- (NSString *)uniqueID;
- (NSUInteger)indexInParentObject;
- (id<BbObjectParent>)parentObject;

@end

@interface BbObject (BbObjectViewDataSource) <BbObjectViewDataSource>

- (NSUInteger)numberOfInlets;
- (NSUInteger)numberOfOutlets;
- (NSString *)titleText;
- (NSValue *)initialPosition;
- (void)BbObjectView:(id<BbObjectView>)sender doAction:(id)anAction;
- (void)BbObjectView:(id<BbObjectView>)sender argumentsDidChange:(NSString *)arguments;
- (void)BbObjectView:(id<BbObjectView>)sender viewForPort:(id)port didMoveToIndex:(NSUInteger)index;

- (NSString *)myViewClass;
- (id<BbObjectView>)createView;
- (BOOL)openView;
- (BOOL)closeView;

@end

@interface BbObject (Ports)

- (BOOL)addInlet:(BbInlet *)inlet;
- (BOOL)addHotInlet:(BbInlet *)inlet targetOutlet:(BbOutlet *)outlet calculateBlock:(BbCalculateBlock)block;
- (BOOL)addOutlet:(BbOutlet *)outlet;

- (BbInlet *)removeInletAtIndex:(NSUInteger)index;
- (BbOutlet *)removeOutletAtIndex:(NSUInteger)index;

- (BOOL)insertInlet:(BbInlet *)inlet atIndex:(NSUInteger)inlet;
- (BOOL)insertOutlet:(BbOutlet *)outlet atIndex:(NSUInteger)outlet;

@end

@interface BbObject (Connections)

- (BOOL)addConnection:(BbConnection *)connection;
- (BbConnection *)removeConnection:(BbConnection *)connection;

@end

@interface BbObject (Meta)

+ (BbObject *)createObject:(NSString *)className arguments:(NSString *)arguments;
+ (id<BbObjectView>)createView:(NSString *)className dataSource:(id<BbObjectViewDataSource>)dataSource;

@end