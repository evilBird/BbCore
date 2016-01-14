//
//  BbConnection.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbObjectChild.h"


@protocol BbConnection <NSObject>

@property    (nonatomic)                    BOOL                needsRedraw;
@property    (nonatomic,getter=isValid)     BOOL                valid;

- (BOOL)validate;
- (UIView *)parentView;
- (UIView *)inletView;
- (UIView *)outletView;

@end

@protocol BbObjectView;


@interface BbConnection : NSObject <BbObject>

@property (nonatomic,weak)                              id <BbObjectParent>                     parent;
@property (nonatomic,weak)                              id <BbObjectChild>                      sender;
@property (nonatomic,weak)                              id <BbObjectChild>                      receiver;

@property (nonatomic,strong)                            NSString                                *uniqueID;

@property (nonatomic)                                   BOOL                                    needsRedraw;
@property (nonatomic,getter=isValid)                    BOOL                                    valid;

- (instancetype)initWithSender:(id<BbObjectChild>)sender
                      receiver:(id<BbObjectChild>)receiver
                        parent:(id<BbObjectParent>)parent;

#pragma mark - BbConnection

- (BOOL)validate;
- (UIView *)parentView;
- (UIView *)inletView;
- (UIView *)outletView;

#pragma mark - BbObject

- (BOOL)startObservingObject:(id<BbObject>)object;
- (BOOL)stopObservingObject:(id<BbObject>)object;

@end

@interface BbConnection (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;
- (NSString *)textDescription;

@end