//
//  BbBoxView.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbBridge.h"

@class BbInletView;
@class BbOutletView;

@interface BbBoxView : UIView

@property (nonatomic,strong)                    UIColor                         *defaultFillColor;
@property (nonatomic,strong)                    UIColor                         *selectedFillColor;
@property (nonatomic,strong)                    UIColor                         *defaultBorderColor;
@property (nonatomic,strong)                    UIColor                         *selectedBorderColor;
@property (nonatomic,strong)                    UIColor                         *defaultTextColor;
@property (nonatomic,strong)                    UIColor                         *selectedTextColor;
@property (nonatomic,strong)                    NSArray                         *inletViews;
@property (nonatomic,strong)                    NSArray                         *outletViews;

@property (nonatomic,getter=isSelected)         BOOL                            selected;
@property (nonatomic,getter=isEditing)          BOOL                            editing;
@property (nonatomic)                           BbObjectViewEditState           editState;

@property (nonatomic,weak)                      id<BbObjectViewDataSource>      dataSource;
@property (nonatomic,weak)                      id<BbObjectViewDelegate>        delegate;
@property (nonatomic,weak)                      id<BbObjectViewEditingDelegate> editingDelegate;

@property (nonatomic,readonly)                  NSValue                         *objectViewPosition;

+ (id<BbObjectView>)createPlaceholder;

- (void)beginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)editingDelegate;

- (instancetype)initWithTitleText:(NSString *)text inlets:(NSUInteger)numInlets outlets:(NSUInteger)numOutlets;

- (void)setTitle:(NSString *)title;

- (void)moveToPoint:(CGPoint)point;

- (void)setPosition:(CGPoint)position;

- (CGPoint)getPosition;

- (NSArray *)positionConstraints;

- (void)updateLayout;

- (void)reloadViewsWithDataSource:(id<BbObjectViewDataSource>)dataSource;

@end

@interface BbBoxView (BbObjectView) <BbObjectView>

#pragma mark - BbObjectView

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource;

- (void)setTitleText:(NSString *)titleText;

- (void)setPositionWithValue:(NSValue *)value;

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

- (void)setDataSource:(id<BbObjectViewDataSource>)dataSource reloadViews:(BOOL)reload;

- (void)doAction:(void(^)(void))action;

- (void)suggestTextCompletion:(id)textCompletion;

@end