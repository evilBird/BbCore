//
//  BbPatchView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbView.h"
#import "BbMessageView.h"
#import "BbScrollView.h"
#import "BbPatchGestureRecognizer.h"

@class BbView;

@interface BbPatchView : UIView <BbEntityView,BbObjectView,BbPatchView,UIScrollViewDelegate>

@property (nonatomic,weak)                              id<BbEntity,BbObject,BbPatch>           entity;

@property (nonatomic,strong)                            NSHashTable                             *childObjectViews;
@property (nonatomic,strong)                            NSHashTable                             *childConnectionPaths;
@property (nonatomic,weak)                              id<BbPatchViewEditingDelegate>          editingDelegate;

@property (nonatomic)                                   BbPatchViewEditState                    editState;
@property (nonatomic)                                   BbEntityViewType                        entityViewType;

@property (nonatomic,strong)                            BbPatchGestureRecognizer                *gesture;
@property (nonatomic,weak)                              BbScrollView                            *scrollView;

@property (nonatomic,weak)                              id<BbEntityView>                        activeInlet;
@property (nonatomic,weak)                              id<BbEntityView>                        activeOutlet;
@property (nonatomic,weak)                              id<BbObjectView>                        activeObject;
@property (nonatomic,weak)                              id<BbObjectView>                        editingObjectView;


+ (id<BbPatchView>)viewWithEntity:(id<BbEntity,BbObject,BbPatch>)entity;

- (void)addChildEntityView:(id<BbEntityView>)entityView;

- (void)removeChildEntityView:(id<BbEntityView>)entityView;

- (void)addConnectionPath:(id<BbConnectionPath>)path;

- (void)removeConnectionPath:(id<BbConnectionPath>)connection;

- (void)cutSelected;

- (NSArray *)copySelected;

@end


