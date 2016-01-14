//
//  BbPatchView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbBridge.h"

typedef NS_ENUM(NSInteger, BbPatchViewType){
    BbPatchViewType_Unknown         =   -1,
    BbPatchViewType_Patch           =   0,
    BbPatchViewType_Object          =   1,
    BbPatchViewType_Inlet           =   2,
    BbPatchViewType_Outlet          =   3,
    BbPatchViewType_ActionObject    =   4,
    BbPatchViewType_ObjectSubview   =   5,
    BbPatchViewType_PatchOutlet     =   6,
};


@protocol BbPatchViewEventDelegate <NSObject>

- (void)patchView:(id)sender didChangeSize:(NSValue *)size;
- (void)patchView:(id)sender didChangeContentOffset:(NSValue *)offset;
- (void)patchView:(id)sender didChangeZoomScale:(NSValue *)zoom;
- (void)patchView:(id)sender setScrollViewShouldBegin:(BOOL)shouldBegin;
- (void)patchView:(id)sender setScrollViewShouldCancel:(BOOL)shouldCancel;

@end

@class BbBoxView;

@interface BbPatchView : UIView

@property (nonatomic,weak)                  id<BbPatchViewEventDelegate>    eventDelegate;
@property (nonatomic)                       BbObjectViewEditState           editState;
@property (nonatomic,getter=isOpen)         BOOL                            open;
@property (nonatomic,strong)                NSHashTable                     *childViews;
@property (nonatomic,strong)                NSHashTable                     *connections;

@property (nonatomic,weak)                  id<BbObjectViewDataSource>      dataSource;
@property (nonatomic,weak)                  id<BbObjectViewEditingDelegate> delegate;


- (void)redrawConnectionsIfNeeded;

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource;

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
