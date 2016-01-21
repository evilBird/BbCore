//
//  BbCoreViewDefinitions.h
//  Pods
//
//  Created by Travis Henspeter on 1/19/16.
//
//

#ifndef BbCoreViewDefinitions_h
#define BbCoreViewDefinitions_h

#import <Foundation/Foundation.h>

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

#define BbIndexInParentNotFound 1e7

@protocol BbEntity;
@protocol BbEntityView;
@protocol BbConnection;
@protocol BbObject;
@protocol BbObjectView;
@protocol BbObjectViewEditingDelegate;
@protocol BbPatch;
@protocol BbPatchView;
@protocol BbPatchViewEditingDelegate;


#endif /* BbCoreViewDefinitions_h */
