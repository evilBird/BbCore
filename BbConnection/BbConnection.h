//
//  BbConnection.h
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BbObjectView.h"
#import "BbObjectChild.h"

@interface BbConnection : NSObject

@property (nonatomic,weak)                              id <BbObjectParent>                     parent;
@property (nonatomic,weak)                              id <BbObjectChild>                      sender;
@property (nonatomic,weak)                              id <BbObjectChild>                      receiver;

@property (nonatomic,strong)                            NSString                                *uniqueID;
@property (nonatomic,strong)                            NSString                                *senderID;
@property (nonatomic,strong)                            NSString                                *receiverID;

@property (nonatomic,strong)                            UIBezierPath                            *path;
@property (nonatomic,readonly)                          UIColor                                 *strokeColor;
@property (nonatomic,readonly)                          CGFloat                                 strokeWidth;

@property (nonatomic)                                   BOOL                                    needsRedraw;
@property (nonatomic,getter=isValid)                    BOOL                                    valid;
@property (nonatomic,getter=isSelected)                 BOOL                                    selected;



- (instancetype)initWithSender:(id<BbObjectChild>)sender
                      receiver:(id<BbObjectChild>)receiver;

#pragma mark - BbConnection

- (BOOL)validate;
- (UIView *)parentView;
- (UIView *)inletView;
- (UIView *)outletView;

@end

@interface BbConnection (BbObject) <BbObject>

- (BOOL)startObservingObject:(id<BbObject>)object;
- (BOOL)stopObservingObject:(id<BbObject>)object;

@end

@interface BbConnection (BbObjectChild) <BbObjectChild>

- (NSUInteger)indexInParent;
- (NSString *)textDescription;

@end