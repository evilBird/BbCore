//
//  BbGestureHandler.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BbGestureAction) {
    BbGestureAction_AddObject,
    BbGestureAction_SelectObject,
    BbGestureAction_DeselectObject,
    BbGestureAction_DragObject,
    BbGestureAction_EditObject,
    BbGestureAction_ShowObjectOptions,
    BbGestureAction_SendObjectActions,
    BbGestureAction_SelectOutlet,
    BbGestureAction_DeselectOutlet,
    BbGestureAction_SelectInlet,
    BbGestureAction_DeselectInlet,
    BbGestureAction_DrawConnection,
    BbGestureAction_DeleteConnection,
    BbGestureAction_Count
};

typedef NS_ENUM(NSInteger, BbGestureStateCondition) {
    BbGestureStateCondition_FirstViewType,
    BbGestureStateCondition_CurrentViewType,
    BbGestureStateCondition_GestureState,
    BbGestureStateCondition_PatchIsEditing,
    BbGestureStateCondition_MultiTouch,
    BbGestureStateCondition_SelectedObject,
    BbGestureStateCondition_SelectedOutlet,
    BbGestureStateCondition_SelectedInlet,
    BbGestureStateCondition_LongDuration,
    BbGestureStateCondition_SignificantMovement,
    BbGestureStateCondition_IsRepeat,
    BbGestureStateCondition_Count
};

@protocol BbGestureHandlerHost <NSObject>

- (void)gestureHandler:(id)sender selectedAction:(BbGestureAction)action;
- (void)gestureHandlerDidCancel:(id)sender;

@end

@interface BbGestureHandler : NSObject

@property (nonatomic,weak)                              id<BbGestureHandlerHost>            host;
@property (nonatomic,getter=isObservingGestures)        BOOL                                observingGestures;

- (instancetype)initWithHost:(id<BbGestureHandlerHost>)host;

- (void)setKeyPath:(NSString *)keyPath forStateCondition:(BbGestureStateCondition)stateCondition;
- (void)setExpression:(NSString *)expression forAction:(BbGestureAction)action;
- (void)beginObservingGestures;
- (void)endObservingGestures;

@end
