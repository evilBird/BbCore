//
//  BbViewProtocols.h
//  Pods
//
//  Created by Travis Henspeter on 1/19/16.
//
//

#ifndef BbViewProtocols_h
#define BbViewProtocols_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BbEntity;
@protocol BbObject;
@protocol BbPatch;

#import "BbCoreUtils.h"

typedef NS_ENUM(NSInteger, BbPatchViewEditState) {
    BbPatchViewEditState_Default    =   0,
    BbPatchViewEditState_Editing    =   1,
    BbPatchViewEditState_Selected   =   2,
    BbPatchViewEditState_Copied     =   3
};

typedef NS_ENUM(NSInteger, BbEntityViewType){
    BbEntityViewType_Unknown         =   -1,
    BbEntityViewType_Patch           =   0,
    BbEntityViewType_Object          =   1,
    BbEntityViewType_Inlet           =   2,
    BbEntityViewType_Outlet          =   3,
    BbEntityViewType_Control         =   4
};

static NSString *kViewArgumentKeyViewClass      =   @"viewClass";
static NSString *kViewArgumentKeyPosition       =   @"position";
static NSString *kViewArgumentKeyContentOffset  =   @"contentOffset";
static NSString *kViewArgumentKeyZoomScale      =   @"zoomScale";
static NSString *kViewArgumentKeySize           =   @"size";

static NSUInteger kViewArgumentIndexPosition_X      =   0;
static NSUInteger kViewArgumentIndexPosition_Y      =   1;
static NSUInteger kViewArgumentIndexSize_Width      =   0;
static NSUInteger kViewArgumentIndexSize_Height     =   1;
static NSUInteger kViewArgumentIndexContentOffset_X =   2;
static NSUInteger kViewArgumentIndexContentOffset_Y =   3;
static NSUInteger kViewArgumentIndexZoomScale       =   4;

#define BbIndexInParentNotFound 1e7

@protocol BbObjectView;

@protocol BbEntityView <NSObject>

@property (nonatomic,weak)                      id<BbEntity>                            entity;
@property (nonatomic,weak)                      id<BbObjectView>                        parentView;
@property (nonatomic,getter=isSelected)         BOOL                                    selected;
@property (nonatomic,strong)                    NSValue                                 *point;

- (BbEntityViewType)entityViewType;

@end

@protocol BbObjectViewEditingDelegate;

@protocol BbObjectView <NSObject,BbEntityView>

@property (nonatomic,weak)                      id<BbEntity, BbObject>                              entity;

@property (nonatomic,weak)                      id<BbEntityView,BbObjectView>                       parentView;

@property (nonatomic,strong)                    NSMutableArray                                      *inletViews;
@property (nonatomic,strong)                    NSMutableArray                                      *outletViews;

@property (nonatomic,strong)                    NSValue                                             *position;
@property (nonatomic,strong)                    NSString                                            *titleText;

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity arguments:(NSString *)arguments;

- (void)addChildEntityView:(id<BbEntityView>)entityView;

- (void)removeChildEntityView:(id<BbEntityView>)entityView;

- (void)updateAppearance;

- (void)setValue:(NSValue *)value forViewArgumentKey:(NSString *)key;

- (NSValue *)getValueForViewArgumentKey:(NSString *)key;

- (id<BbEntityView>)getViewForEntity:(id<BbEntity>)entity;

- (void)removeViewForEntity:(id<BbEntity>)entity;

- (void)addViewForEntity:(id<BbEntity>)entity;

- (void)setEntity:(id<BbEntity>)entity forInletViewAtIndex:(NSUInteger)index;

- (void)setEntity:(id<BbEntity>)entity forOutletViewAtIndex:(NSUInteger)index;

- (BOOL)canEdit;

@optional

@property (nonatomic,getter=isEditing)          BOOL                                    editing;
@property (nonatomic,weak)                      id<BbObjectViewEditingDelegate>         editingDelegate;
@property (nonatomic,strong)                    id                                      textField;

- (BOOL)beginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)delegate;

@end

@protocol BbObjectViewEditingDelegate <NSObject>

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText;

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithUserText:(NSString *)userText;

@end

@protocol BbPatchView <NSObject,BbEntityView,BbObjectView>

@property (nonatomic,weak)                      id<BbEntity,BbObject,BbPatch>                             entity;
@property (nonatomic,strong)                      NSHashTable                           *childObjectViews;
@property (nonatomic,strong)                      NSHashTable                           *childConnections;
@property (nonatomic,weak)                      id<BbObjectViewEditingDelegate>          editingDelegate;
@property (nonatomic)                             BbPatchViewEditState                  editState;

+ (id<BbPatchView>)viewWithEntity:(id<BbEntity,BbObject,BbPatch>)entity arguments:(NSString *)arguments;

- (void)addChildEntityView:(id<BbObjectView>)entityView;

- (void)addConnectionPath:(id)path;

- (void)removeConnectionPath:(id)connection;

- (BOOL)setEditState:(BbPatchViewEditState)state withDelegate:(id<BbObjectViewEditingDelegate>)delegate;

- (void)cutSelectedChildEntityViews;

- (NSArray *)copySelectedChildEntityViews;

- (void)pasteChildEntityViews:(NSArray *)childObjects;

@end

@protocol BbPatchViewEditingDelegate <NSObject>

- (void)patchView:(id<BbPatchView>)sender didChangeEditState:(BbPatchViewEditState)editState;

- (void)patchView:(id<BbPatchView>)sender didEdit:(id)editObject;

- (BOOL)patchViewCanUndo:(id<BbPatchView>)sender;

- (BOOL)patchViewCanRedo:(id<BbPatchView>)sender;

- (void)undoChangeInPatchView:(id<BbPatchView>)sender;

- (void)redoChangeInPatchView:(id<BbPatchView>)sender;

- (void)patchView:(id<BbPatchView>)sender didAddChildObjectView:(id<BbObjectView>)objectView forDependencyWithIdentifier:(id)dependencyID;

- (void)patchView:(id<BbPatchView>)sender didRequestSupplementaryViewWithIdentifier:(id)supplementaryViewIdentifier forChildObjectView:(id<BbObjectView>)objectView;

- (void)patchView:(id<BbPatchView>)sender didDismissSupplementaryView:(id<BbObjectView>)supplementaryView;


@end

#endif /* BbViewProtocols_h */
