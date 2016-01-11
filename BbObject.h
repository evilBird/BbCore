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

@interface BbObject : NSObject  <BbObjectParent,BbObjectChild,BbObjectViewDataSource>

@property (nonatomic,strong)                NSString                                *titleText;
@property (nonatomic,strong)                NSString                                *arguments;
@property (nonatomic,readonly)              NSArray                                 *inlets;
@property (nonatomic,readonly)              NSArray                                 *outlets;
@property (nonatomic,readonly)              NSArray                                 *children;
@property (nonatomic,readonly)              NSArray                                 *connections;

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

- (BOOL)addInlet:(BbInlet *)inlet;
- (BOOL)addHotInlet:(BbInlet *)inlet targetOutlet:(BbOutlet *)outlet calculateBlock:(BbCalculateBlock)block;
- (BOOL)addOutlet:(BbOutlet *)outlet;

- (BOOL)addChildObject:(BbObject<BbObjectChild>*)child;
- (BbObject<BbObjectChild>*)removeChildObject:(BbObject<BbObjectChild>*)child;

- (BOOL)addConnection:(BbConnection *)connection;
- (BbConnection *)removeConnection:(BbConnection *)connection;

- (BbInlet *)removeInletAtIndex:(NSUInteger)index;
- (BbOutlet *)removeOutletAtIndex:(NSUInteger)index;

- (BOOL)insertInlet:(BbInlet *)inlet atIndex:(NSUInteger)inlet;
- (BOOL)insertOutlet:(BbOutlet *)outlet atIndex:(NSUInteger)outlet;

+ (BbCalculateBlock)passThruCalculateBlock;
- (NSString *)textDescription;
+ (NSString *)myToken;

- (NSString *)myViewClass;
- (id<BbObjectView>)createView;
- (BOOL)openView;
- (BOOL)closeView;

#pragma mark - BbObjectViewDataSource

- (NSUInteger)numberOfInlets;
- (NSUInteger)numberOfOutlets;
- (NSString *)titleText;
- (NSValue *)initialPosition;
- (void)BbObjectView:(id<BbObjectView>)sender argumentsDidChange:(NSString *)arguments;
- (void)BbObjectView:(id<BbObjectView>)sender viewForPort:(id)port didMoveToIndex:(NSUInteger)index;

@end

@interface BbObject (Ports)


@end

@interface BbObject (Meta)
+ (NSString *)testDescription;
+ (NSString *)viewArgsFromText:(NSString *)text;
+ (NSString *)objectArgsFromText:(NSString *)text;
+ (BbObject *)objectWithTextDescription:(NSString *)text;
+ (BbObject *)createObject:(NSString *)className arguments:(NSString *)arguments;
+ (id<BbObjectView>)createView:(NSString *)className dataSource:(id<BbObjectViewDataSource>)dataSource;

@end