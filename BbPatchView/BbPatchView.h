//
//  BbPatchView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbView.h"



@protocol BbPatchViewEventDelegate <NSObject>

- (void)patchView:(id)sender didChangeSize:(NSValue *)size;
- (void)patchView:(id)sender didChangeContentOffset:(NSValue *)offset;
- (void)patchView:(id)sender didChangeZoomScale:(NSValue *)zoom;
- (void)patchView:(id)sender setScrollViewShouldBegin:(BOOL)shouldBegin;
- (void)patchView:(id)sender setScrollViewShouldCancel:(BOOL)shouldCancel;

@end

@class BbView;

@interface BbPatchView : UIView

@property (nonatomic,weak)                  id<BbPatchViewEventDelegate>    eventDelegate;
@property (nonatomic)                       BbObjectViewEditState           editState;
@property (nonatomic,getter=isOpen)         BOOL                            open;
@property (nonatomic,strong)                NSHashTable                     *childViews;
@property (nonatomic,strong)                NSHashTable                     *connections;
@property (nonatomic,strong)                NSMapTable                      *pathConnectionMap;
@property (nonatomic,strong)                NSString                        *pasteBoard;

@property (nonatomic,weak)                  id<BbObjectViewDataSource>      dataSource;
@property (nonatomic,weak)                  id<BbObjectViewDelegate>        delegate;
@property (nonatomic,weak)                  id<BbObjectViewEditingDelegate> editingDelegate;

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource;
- (void)updateAppearance;

- (void)cutSelected;
- (void)copySelected;
- (void)abstractCopied;

@end

@interface BbPatchView (Gestures)

@end

@interface BbPatchView (BbObjectView) <BbObjectView>


- (void)layoutSubviews;

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource;

- (void)setTitleText:(NSString *)titleText;

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

- (void)removeChildObjectView:(id<BbObjectView>)view;

- (void)addChildObjectView:(id<BbObjectView>)view;

- (void)setSizeWithValue:(NSValue *)value;

- (void)setZoomScaleWithValue:(NSValue *)value;

- (void)setContentOffsetWithValue:(NSValue *)value;

- (void)addConnection:(id<BbConnection>)connection;

- (void)removeConnection:(id<BbConnection>)connection;

@end
