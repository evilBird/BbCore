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

#pragma mark - Enumerations

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

#pragma mark - Constants

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

#pragma mark - BbEntityView Protocol

@protocol BbEntityView <NSObject>

@property (nonatomic,weak)                      id<BbEntity>                                        entity;
@property (nonatomic)                           BbEntityViewType                                    entityViewType;

@optional

@property (nonatomic,weak)                      id<BbEntityView>                                    parentView;
@property (nonatomic,getter=isSelected)         BOOL                                                selected;


@end

@protocol BbConnection;
@protocol BbPatchView;

@protocol BbConnectionPath <NSObject>

@property (nonatomic,weak)                      id<BbEntity,BbConnection>                           entity;
@property (nonatomic,getter=isSelected)         BOOL                                                selected;
@property (nonatomic,getter=isValid)            BOOL                                                valid;
@property (nonatomic)                           BOOL                                                needsRedraw;
@property (nonatomic,strong)                    NSValue                                             *startPoint;
@property (nonatomic,strong)                    NSValue                                             *endPoint;


@property (nonatomic,readonly)                  id                                                  bezierPath;
@property (nonatomic,readonly)                  id                                                  color;

@end

@protocol BbObjectViewEditingDelegate;

#pragma mark - BbObjectView Protocol

@protocol BbObjectView <NSObject,BbEntityView>

@property (nonatomic,weak)                      id<BbEntity, BbObject>                              entity;

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity;

- (void)addChildEntityView:(id<BbEntityView>)entityView;

- (void)removeChildEntityView:(id<BbEntityView>)entityView;

- (NSArray *)positionConstraints;

- (void)updateAppearance;

@optional

- (void)insertChildEntityView:(id<BbEntityView>)entityView atIndex:(NSUInteger)index;

@property (nonatomic,getter=isEditing)          BOOL                                                editing;
@property (nonatomic,weak)                      id<BbObjectViewEditingDelegate>                     editingDelegate;
@property (nonatomic,strong)                    id                                                  textField;
@property (nonatomic,weak)                      id<BbEntityView,BbObjectView>                       parentView;
@property (nonatomic,strong)                    NSHashTable                                         *inletViews;
@property (nonatomic,strong)                    NSHashTable                                         *outletViews;

@property (nonatomic,strong)                    NSValue                                             *position;
@property (nonatomic,strong)                    NSString                                            *titleText;
@property (nonatomic,getter=isHighlighted)      BOOL                                                highlighted;
@property (nonatomic,getter=isPlaceholder)      BOOL                                                placeholder;

- (BOOL)beginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)delegate;

- (void)setValue:(NSValue *)value forViewArgumentKey:(NSString *)key;

- (NSValue *)getValueForViewArgumentKey:(NSString *)key;

- (void)moveToPoint:(NSValue *)pointValue;

- (void)moveToPosition:(NSValue *)positionValue;

- (BOOL)canEdit;

@end

#pragma mark - BbObjectViewEditingDelegate Protocol

@protocol BbObjectViewEditingDelegate <NSObject>

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText;

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithUserText:(NSString *)userText;

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText;

@end

#pragma mark - BbPatchView Protocol
@protocol BbPatchViewEditingDelegate;

@protocol BbPatchView <NSObject,BbEntityView,BbObjectView>

@property (nonatomic,weak)                          id<BbEntity,BbObject,BbPatch>           entity;
@property (nonatomic,strong)                        NSHashTable                             *childObjectViews;
@property (nonatomic,strong)                        NSHashTable                             *childConnectionPaths;
@property (nonatomic,weak)                          id<BbObjectViewEditingDelegate>         editingDelegate;
@property (nonatomic)                               BbPatchViewEditState                    editState;

+ (id<BbPatchView>)viewWithEntity:(id<BbEntity,BbObject,BbPatch>)entity;

- (void)addConnectionPath:(id<BbConnectionPath>)path;

- (void)removeConnectionPath:(id<BbConnectionPath>)connection;

- (BOOL)setEditState:(BbPatchViewEditState)state withDelegate:(id<BbPatchViewEditingDelegate>)delegate;

- (void)cutSelectedChildEntityViews;

- (NSArray *)copySelectedChildEntityViews;

- (void)pasteChildEntityViews:(NSArray *)childObjects;

@end

#pragma mark - BbPatchViewEditingDelegate

@protocol BbPatchViewEditingDelegate <NSObject>

- (void)patchView:(id<BbPatchView>)sender didChangeEditState:(BbPatchViewEditState)editState;

- (void)patchView:(id<BbPatchView>)sender didEdit:(id)editObject;

- (BOOL)patchViewCanUndo:(id<BbPatchView>)sender;

- (BOOL)patchViewCanRedo:(id<BbPatchView>)sender;

- (void)undoChangeInPatchView:(id<BbPatchView>)sender;

- (void)redoChangeInPatchView:(id<BbPatchView>)sender;

- (void)patchView:(id<BbPatchView>)sender didAddChildEntityView:(id<BbObjectView>)objectView forDependencyWithIdentifier:(id)dependencyID;

- (void)patchView:(id<BbPatchView>)sender didRequestSupplementaryViewWithIdentifier:(id)supplementaryViewIdentifier forChildObjectView:(id<BbObjectView>)objectView;

- (void)patchView:(id<BbPatchView>)sender didDismissSupplementaryView:(id<BbObjectView>)supplementaryView;


@end

#endif /* BbViewProtocols_h */
