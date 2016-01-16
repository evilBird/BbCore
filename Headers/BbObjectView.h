//
//  BbObjectView.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbObjectView_h
#define BbObjectView_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BbObjectViewEditState) {
    BbObjectViewEditState_Default    =   0,
    BbObjectViewEditState_Editing    =   1,
    BbObjectViewEditState_Selected   =   2,
    BbObjectViewEditState_Copied     =   3
};

typedef NS_ENUM(NSInteger, BbObjectViewEditingEvent) {
    BbObjectViewEditingEvent_Began,
    BbObjectViewEditingEvent_Changed,
    BbObjectViewEditingEvent_Ended,
    BbObjectViewEditingEvent_Cancelled
};

@protocol BbObjectView;

@protocol BbObjectViewDataSource <NSObject>

@property (nonatomic,strong)            NSString            *uniqueID;

@optional

- (NSUInteger)numberOfInletsForObjectView:(id<BbObjectView>)objectView;

- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView;

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)contentOffsetForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)zoomScaleForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)sizeForObjectView:(id<BbObjectView>)objectView;

#pragma mark - Determine what actions can be done with an object view

- (void)doSelectors;

- (BOOL)objectView:(id<BbObjectView>)sender canOpenChildView:(id<BbObjectView>)child;

- (BOOL)objectView:(id<BbObjectView>)sender canTestObjectForChildView:(id<BbObjectView>)child;

- (BOOL)objectView:(id<BbObjectView>)sender canOpenHelpObjectForChildView:(id<BbObjectView>)child;

@end

@protocol BbObjectViewDelegate <NSObject>

@optional

#pragma mark - View argument change handlers

- (void)objectView:(id<BbObjectView>)sender didChangePosition:(NSValue *)position;

- (void)objectView:(id<BbObjectView>)sender didChangeContentOffset:(NSValue *)offset;

- (void)objectView:(id<BbObjectView>)sender didChangeZoomScale:(NSValue *)zoomScale;

- (void)objectView:(id<BbObjectView>)sender didChangeSize:(NSValue *)viewSize;

#pragma mark - Add/remove child object views

- (void)objectView:(id<BbObjectView>)sender didAddChildObjectView:(id<BbObjectView>)child;

- (void)objectView:(id<BbObjectView>)sender didRemoveChildObjectView:(id<BbObjectView>)child;

#pragma mark - Port Views

- (void)objectView:(id<BbObjectView>)sender didAddPortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope atIndex:(NSUInteger)index;

- (void)objectView:(id<BbObjectView>)sender didRemovePortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope atIndex:(NSUInteger)index;

- (void)objectView:(id<BbObjectView>)sender didMovePortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope toIndex:(NSUInteger)index;

- (void)objectView:(id<BbObjectView>)sender didConnectPortView:(id<BbObjectView>)sendingPortView toPortView:(id<BbObjectView>)receivingPortView;

- (void)objectView:(id<BbObjectView>)sender didDisconnectPortView:(id<BbObjectView>)sendingPortView fromPortView:(id<BbObjectView>)receivingPortView;

#pragma mark - Target/Action type methods

- (void)sendActionsForObjectView:(id<BbObjectView>)sender;

#pragma mark - Open close selected object views

- (void)objectView:(id<BbObjectView>)sender didOpenChildView:(id<BbObjectView>)child;

- (void)objectView:(id<BbObjectView>)sender didOpenHelpForChildView:(id<BbObjectView>)child;

- (void)objectView:(id<BbObjectView>)sender didOpenTestForChildView:(id<BbObjectView>)child;

- (void)objectView:(id<BbObjectView>)sender didCloseChildView:(id<BbObjectView>)child;

@end

@protocol BbObjectViewEditingDelegate <NSObject,BbObjectViewDelegate>

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)objectView;

- (void)objectView:(id<BbObjectView>)objectView didEditText:(NSString *)text;

- (BOOL)objectView:(id<BbObjectView>)objectView shouldEndEditingWithText:(NSString *)text;

#pragma mark - Editing state change handler

- (void)objectView:(id<BbObjectView>)sender didChangeEditState:(NSInteger)editState;

#pragma mark - Undo/Redo

- (BOOL)objectViewDidUndo:(id<BbObjectView>)sender;

- (BOOL)objectViewDidRedo:(id<BbObjectView>)sender;

#pragma mark - Editing actions

- (void)objectView:(id<BbObjectView>)sender didCopySelected:(NSArray*)selectedObjectViews;

- (void)objectView:(id<BbObjectView>)sender didCutSelected:(NSArray*)selectedObjectViews;

- (void)objectViewDidPasteCopied:(id<BbObjectView>)sender;

- (void)objectView:(id<BbObjectView>)sender didAbstractSelected:(NSArray *)selectedObjectViews withArguments:(NSString *)arguments;

@end

@protocol BbConnection <NSObject>

@property    (nonatomic)                    BOOL                needsRedraw;
@property    (nonatomic,getter=isValid)     BOOL                valid;

- (BOOL)validate;
- (UIView *)parentView;
- (UIView *)inletView;
- (UIView *)outletView;

@end

@protocol BbObjectView <NSObject>

@property (nonatomic,weak)                  id<BbObjectViewDataSource>      dataSource;
@property (nonatomic,weak)                  id<BbObjectViewDelegate>        delegate;
@property (nonatomic,weak)                  id<BbObjectViewEditingDelegate> editingDelegate;
@property (nonatomic,getter=isSelected)     BOOL                            selected;
@property (nonatomic,getter=isEditing)      BOOL                            editing;

- (void)removeFromSuperView;

@optional

@property (nonatomic,readonly)        NSValue                       *objectViewPosition;

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource;

- (void)updateLayout;

- (BOOL)canEdit;

- (CGPoint)center;

- (UIView *)superview;

- (void)moveToPoint:(CGPoint)point;

- (NSArray *)positionConstraints;

- (void)setTitleText:(NSString *)titleText;

- (void)setPositionWithValue:(NSValue *)value;

- (void)removeChildObjectView:(id<BbObjectView>)view;

- (void)addChildObjectView:(id<BbObjectView>)view;

- (void)setSizeWithValue:(NSValue *)value;

- (void)setZoomScaleWithValue:(NSValue *)value;

- (void)setContentOffsetWithValue:(NSValue *)value;

- (void)addConnection:(id<BbConnection>)connection;

- (void)removeConnection:(id<BbConnection>)connection;

- (void)setDataSource:(id<BbObjectViewDataSource>)dataSource reloadViews:(BOOL)reload;

- (void)doAction:(void(^)(void))action;

- (void)suggestTextCompletion:(id)textCompletion;

+ (id<BbObjectView>)createPlaceholder;

- (id<BbObjectView>)initWithDataSource:(id<BbObjectViewDataSource>)dataSource;

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

@end

#endif /* BbObjectView_h */
