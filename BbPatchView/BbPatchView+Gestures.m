//
//  BbPatchView+Gestures.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbPatchView.h"
#import "BbPatchGestureRecognizer.h"
#import "BbPlaceholderView.h"

static double kMaxMovement = 5.0;
static double kMaxDuration = 0.5;

typedef NS_ENUM(NSUInteger, StateVariable) {
    StateVariable_ViewType,
    StateVariable_PatchEditing,
    StateVariable_ViewEditing,
    StateVariable_MultiTouch,
    StateVariable_Repeats,
    StateVariable_Movement,
    StateVariable_Duration,
    StateVariable_GestureState,
    StateVariable_ActiveOutlet,
    StateVariable_ActiveInlet,
    StateVariable_ActiveObject,
    StateVariable_MultiSelected,
    StateVariable_Count
};

typedef NS_ENUM(NSUInteger, GenericHandler) {
    GenericHandler_DoNothing,
    GenericHandler_PreventScrolling,
    GenericHandler_StopTracking,
    GenericHandler_SetActiveView,
    GenericHandler_UnsetActiveView,
    GenericHandler_MoveView,
    GenericHandler_ToggleEditView,
    GenericHandler_AddPlaceholder,
    GenericHandler_SetActiveOutlet,
    GenericHandler_UnsetActiveOutlet,
    GenericHandler_SetActiveInlet,
    GenericHandler_UnsetActiveInlet,
    GenericHandler_DrawConnection,
    GenericHandler_MakeConnection,
    GenericHandler_DeleteConnection,
    GenericHandler_ShowOptions,
    GenericHandler_UpdateAppearance,
    GenericHandler_ResetState
};

typedef void (^GenericHandlerBlock)(void);

NSUInteger state[StateVariable_Count];

@implementation BbPatchView (Gestures)

- (void)handleGesture:(BbPatchGestureRecognizer *)gesture
{
    //State variables
    // View type
    // Patch is editing
    // View is editing
    // Gesture touch ct > 1
    // Gesture repeat ct > 0
    // Gesture movement > max movment
    // Gesure duration > max duration
    
    state[StateVariable_ViewType] = (NSUInteger)(gesture.currentViewType);
    state[StateVariable_PatchEditing] = (NSUInteger)(self.editState > BbPatchViewEditState_Default);
    state[StateVariable_ViewEditing] = (NSUInteger)(gesture.currentView.isEditing);
    state[StateVariable_MultiTouch] = (NSUInteger)(gesture.numberOfTouches > 1);
    state[StateVariable_Repeats] = (NSUInteger)(gesture.repeatCount > 0);
    state[StateVariable_Movement] = (NSUInteger)(gesture.movement > kMaxMovement);
    state[StateVariable_Duration] = (NSUInteger)(gesture.duration > kMaxDuration);
    state[StateVariable_GestureState] = (NSUInteger)(gesture.state);
}

- (NSArray *)patchViewHandlersForState:(NSUInteger [])stateVector
{
    if ( stateVector[StateVariable_MultiTouch] || stateVector[StateVariable_Repeats] ) {
       
        return @[@(GenericHandler_StopTracking),@(GenericHandler_ResetState)];
    }
    
    switch (stateVector[StateVariable_GestureState]) {
        case 1:
        {
            
        }
            break;
        case 2:
        {
            if ( stateVector[StateVariable_ActiveOutlet] ) {
                return @[@(GenericHandler_PreventScrolling),@(GenericHandler_DrawConnection)];
            }
            
            if ( stateVector[StateVariable_ActiveObject] ) {
                return @[@(GenericHandler_PreventScrolling),@(GenericHandler_MoveView)];
            }
            
            if ( stateVector[StateVariable_Movement] ) {
                return @[@(GenericHandler_StopTracking),@(GenericHandler_ResetState)];
            }
        }
            break;
        case 3:
        {
            if ( stateVector[StateVariable_PatchEditing] ) {
                
            }else{
                
            }
        }
            break;
        default:
            break;
    }
    
    
    
}

- (void)objectViewHandlerForStateVector:(NSUInteger [])stateVector
{
    
}

- (GenericHandlerBlock)getGenericHandlerBlock:(GenericHandler)genericHandler
{
    __weak BbPatchView *weakself = self;
    GenericHandlerBlock handlerBlock = NULL;
    switch (genericHandler) {
        case GenericHandler_StopTracking:
        {
            handlerBlock = ^(void){
                [weakself.gesture stopTracking];
                [weakself.scrollView setTouchesShouldBegin:YES];
                [weakself.scrollView setTouchesShouldCancel:NO];
            };
        }
            break;
        case GenericHandler_PreventScrolling:
        {
            handlerBlock = ^( void ){
                [weakself.scrollView setTouchesShouldBegin:NO];
                [weakself.scrollView setTouchesShouldCancel:YES];
            };
        }
            break;
        case GenericHandler_SetActiveView:
        {
            handlerBlock = ^( void ){
                weakself.activeObject = weakself.gesture.currentView;
            };
        }
            break;
        case GenericHandler_UnsetActiveView:
        {
            handlerBlock = ^( void ){
                weakself.activeObject = nil;
            };
        }
            break;
        case GenericHandler_SetActiveOutlet:
        {
            handlerBlock = ^( void ){
                weakself.activeOutlet = weakself.gesture.currentView;
            };
        }
            break;
        case GenericHandler_UnsetActiveOutlet:
        {
            handlerBlock = ^( void ){
                weakself.activeOutlet = nil;
            };
        }
            break;
        case GenericHandler_SetActiveInlet:
        {
            handlerBlock = ^( void ){
                weakself.activeInlet = weakself.gesture.currentView;
            };
        }
            break;
        case GenericHandler_UnsetActiveInlet:
        {
            handlerBlock = ^( void ){
                weakself.activeInlet = nil;
            };
        }
            break;
        case GenericHandler_MoveView:
        {
            handlerBlock = ^( void ){
                BbAbstractView *view = (BbAbstractView *)weakself.gesture.firstView;
                CGPoint position = view.position.CGPointValue;
                CGPoint point = [weakself myPosition2Point:position];
                point.x+=weakself.gesture.deltaLocation.x;
                point.y+=weakself.gesture.deltaLocation.y;
                CGPoint offsets = [weakself point2ConstraintOffsets:point];
                CGPoint newPosition = [weakself myPoint2Position:point];
                view.centerXConstraint.constant = offsets.x;
                view.centerYConstraint.constant = offsets.y;
                [view positionDidChange:[NSValue valueWithCGPoint:newPosition]];
                [weakself updateAppearance];
            };
        }
            break;
        case GenericHandler_ToggleEditView:
        {
            handlerBlock = ^ ( void ){
                if ( weakself.gesture.currentView.isEditing ) {
                    weakself.gesture.currentView.editing = NO;
                }else if ( [weakself.gesture.currentView canEdit] ){
                    weakself.gesture.currentView.editing = YES;
                }
            };
        }
            break;
        case GenericHandler_AddPlaceholder:
        {
            handlerBlock = ^ (void){
                CGPoint loc = weakself.gesture.location;
                CGPoint myLoc = [weakself convertPoint:loc fromView:self.gesture.view];
                myLoc.x /= weakself.scrollView.zoomScale;
                myLoc.y /= weakself.scrollView.zoomScale;
                
                id <BbObjectView> placeholder = [[BbPlaceholderView alloc]initWithPosition:[NSValue valueWithCGPoint:weakself.gesture.position]];
                [weakself addChildEntityView:placeholder];
                [placeholder updateAppearance];
                [weakself.entity patchView:weakself didAddPlaceholderObjectView:placeholder];
            };
        }
            break;
        case GenericHandler_DrawConnection:
        {
            handlerBlock = ^(void){
                [weakself drawConnection];
            };
        }
            break;
        case GenericHandler_MakeConnection:
        {
            handlerBlock = ^(void){
                [weakself makeConnection];
            };
        }
            break;
        case GenericHandler_DeleteConnection:
        {
            handlerBlock = ^ (void){
                id<BbConnectionPath> toRemove = nil;
                
                for (id<BbConnectionPath> aPath in weakself.childConnectionPaths.allObjects ) {
                    UIBezierPath *path = [aPath bezierPath];
                    if ( [weakself bezierPath:path containsPoint:weakself.gesture.location] ) {
                        toRemove = aPath;
                        break;
                    }
                }
                
                if ( nil != toRemove ) {
                    [weakself removeConnectionPath:toRemove];
                    [weakself.entity patchView:weakself didRemoveChildConnection:toRemove.entity];
                }
            };
        }
            break;
        case GenericHandler_ShowOptions:
        {
            handlerBlock = ^(void){
                [weakself showCurrentViewOptions];
            };
        }
            break;
        case GenericHandler_ResetState:
        {
            handlerBlock = ^(void){
                [weakself resetGestureStateConditions];
            };
        }
            break;
        default:
        {
            handlerBlock = ^(void){
                [weakself doNothing];
            };
        }
            break;
    }
    
    return [handlerBlock copy];
}

- (void)setActiveView:(id)view
{
    self.activeObject = view;
}

- (void)toggleCurrentViewEditing
{
    
}

- (void)moveCurrentView
{
    
}

- (void)addPlaceholderView
{
    
}

- (void)drawConnection
{
    
}

- (void)makeConnection
{
    
}

- (void)showCurrentViewOptions
{
    
}

- (void)resetGestureState
{
    
}

- (void)doNothing
{
    
}

@end
