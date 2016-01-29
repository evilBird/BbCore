//
//  BbPatchView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbPatchView.h"
#import "BbPortView.h"
#import "BbCoreProtocols.h"
#import "UIView+BbPatch.h"
#import "BbPlaceholderView.h"

static NSTimeInterval       kLongPressMinDuration = 0.5;
static CGFloat              kMaxMovement          = 5.0;

@interface BbPatchView () <UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)        UIBezierPath                        *activePath;
@property (nonatomic,strong)        NSHashTable                         *childEntityViewQueue;
@property (nonatomic,strong)        NSHashTable                         *childConnectionQueue;
@property (nonatomic,strong)        NSTimer                             *longPressTimer;
@property (nonatomic)               CGFloat                             keyboardOffset;

@end

@implementation BbPatchView

#pragma mark - Constructors

+ (id<BbPatchView>)viewWithEntity:(id<BbEntity,BbObject,BbPatch>)entity
{
    BbPatchView *patchView = [[BbPatchView alloc]initWithEntity:entity];
    return patchView;
}

- (instancetype)initWithEntity:(id<BbEntity,BbObject,BbPatch>)entity
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        _entity = entity;
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.gesture = [[BbPatchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    self.gesture.cancelsTouchesInView = NO;
    self.gesture.delaysTouchesBegan = YES;
    self.gesture.delaysTouchesEnded = YES;
    self.gesture.delegate = self;
    [self addGestureRecognizer:self.gesture];
    
    self.childObjectViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.childConnectionPaths = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.childEntityViewQueue = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.childConnectionQueue = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.entityViewType = BbEntityViewType_Patch;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSValue *val = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [val CGRectValue];
    CGFloat height = frame.size.height;
    CGPoint contentOffset = self.scrollView.contentOffset;
    contentOffset.y += height;
    self.keyboardOffset = height;
    [self.scrollView setContentOffset:contentOffset animated:YES];

}

- (void)keyboardDidHide:(NSNotification *)notification
{
    NSValue *val = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [val CGRectValue];
    CGFloat height = frame.size.height;
    CGPoint contentOffset = self.scrollView.contentOffset;
    contentOffset.y -= height;
    [self.scrollView setContentOffset:contentOffset animated:YES];
}

#pragma mark - PatchView Editing
- (void)cutSelected
{
    NSArray *selectedObjects = [self getSelectedObjects];
    for (id<BbObjectView> anObjectView in selectedObjects ) {
        [self removeChildEntityView:anObjectView];
        [self.entity patchView:self didRemoveChildObjectView:anObjectView];
    }
}

- (NSArray *)copySelected
{
    return [self getSelectedObjects];
}

#pragma mark - Gestures

- (void)cancelScrollingIfNeeded
{
    CGRect rect = [self.superview bounds];
    CGRect insetRect = CGRectInset(rect, 50.0, 50.0);
    CGPoint loc = [self.superview convertPoint:self.gesture.location fromView:self];
    if ( !CGRectContainsPoint(insetRect, loc) ) {
        self.scrollView.touchesShouldBegin = NO;
        self.scrollView.touchesShouldCancel = YES;
    }
}

- (void)handleGesture:(BbPatchGestureRecognizer *)gesture
{
    
    if ( gesture.state == UIGestureRecognizerStateCancelled ) {
        self.scrollView.touchesShouldBegin = YES;
        self.scrollView.touchesShouldCancel = NO;
        [self resetGestureStateConditions];
        
    }else if ( gesture.numberOfTouches > 1 ){
        
        [self.gesture stopTracking];
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self cancelScrollingIfNeeded];
            [self handleGestureBegan:gesture];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self handleGestureMoved:gesture];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self handleGestureEnded:gesture];
        }
            break;
            
        default:
            break;
    }
}

- (void)longPressDetected:(id)sender
{
    if ( self.gesture.isTracking && self.gesture.movement < kMaxMovement ) {
        
        if ( self.gesture.firstViewType == BbEntityViewType_Patch && self.gesture.currentViewType == BbEntityViewType_Patch ) {
            [self addPlaceholderObjectView];
        }else if ( self.gesture.currentViewType == BbEntityViewType_Object || self.gesture.currentViewType == BbEntityViewType_Control ){
            if ( self.editState == BbPatchViewEditState_Default ) {
                if ( self.gesture.currentView.isEditing ) {
                    self.gesture.currentView.editing = NO;
                }else if ( [self.gesture.currentView canEdit] ){
                    self.gesture.currentView.editing = YES;
                }
            }
        }

    }
}

- (void)handleGestureBegan:(BbPatchGestureRecognizer *)gesture
{
    if ( self.longPressTimer.isValid ) {
        [self.longPressTimer invalidate];
    }
    
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:kLongPressMinDuration
                                                           target:self
                                                         selector:@selector(longPressDetected:)
                                                         userInfo:nil
                                                          repeats:NO];
    switch (gesture.currentViewType) {
            
        case BbEntityViewType_Control:
        case BbEntityViewType_Object:
        {
            if ( gesture.currentView.isEditing ) {
                [gesture stopTracking];
                return;
            }else{
                self.activeObject = gesture.currentView;
            }
        }
            break;
        case BbEntityViewType_Outlet:
        {
            if ( self.editState == BbPatchViewEditState_Default ) {
                self.scrollView.touchesShouldBegin = NO;
                self.activeOutlet = gesture.currentView;
            }
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    [self updateAppearance];
}


- (void)handleGestureMoved:(BbPatchGestureRecognizer *)gesture
{
    if ( gesture.currentViewType == BbEntityViewType_Inlet ) {
        
        if ( self.editState == BbPatchViewEditState_Default ) {
            
            if ( self.activeOutlet ) {
                self.activeInlet = gesture.currentView;
            }else{
                self.activeInlet = nil;
            }
        }
    }else{
        
        self.activeInlet = nil;
        
        if ( self.activeObject ){
            [self.scrollView touchesShouldCancel];
            [self moveSelectedObjectViewsWithDelta:gesture.deltaLocation];
        }else if ( !self.activeOutlet && gesture.movement > kMaxMovement ){
            [gesture stopTracking];
        }
    }
    
    [self updateAppearance];

}

- (void)handleGestureEnded:(BbPatchGestureRecognizer *)gesture
{
    switch ( gesture.currentViewType ) {
            
        case BbEntityViewType_Inlet:
        {
            if ( self.editState == BbPatchViewEditState_Default ) {
                if ( nil != self.activeOutlet && nil != self.activeInlet ) {
                    //make connection
                    [(id<BbPatch>)self.entity patchView:self didConnectOutletView:self.activeOutlet toInletView:self.activeInlet];
                }
            }
        }
            break;
        case BbEntityViewType_Patch:
        {
            if ( self.editState == BbPatchViewEditState_Default ) {
                if ( nil != self.activeInlet && nil != self.activeOutlet ) {
                    [(id<BbPatch>)self.entity patchView:self didConnectOutletView:self.activeOutlet toInletView:self.activeInlet];
                }
            }else{
                [self deleteConnectionsIfNeeded];
            }
        }
            break;
        case BbEntityViewType_Object:
        {
            if ( self.editState > BbPatchViewEditState_Default ) {
                gesture.currentView.selected = !(gesture.currentView.isSelected);
                [self updateEditState];
            }
        }
            break;
            
        case BbEntityViewType_Control:
        {
            if ( self.editState == BbPatchViewEditState_Default ) {
                if ( gesture.duration < kLongPressMinDuration ) {
                    [self.longPressTimer invalidate];
                    [(id<BbObject>)[gesture.currentView entity]sendActionsForView:gesture.currentView];
                }
            }else{
                gesture.currentView.selected = !(gesture.currentView.isSelected);
                [self updateEditState];
            }
        }
            break;
        default:
            break;
    }
    
    [self resetGestureStateConditions];
}

- (void)updateEditState
{
    NSArray *selected = [self getSelectedObjects];
    
    switch ( self.editState ) {
        case BbPatchViewEditState_Editing:
        {
            if ( nil != selected && selected.count ) {
                self.editState = BbPatchViewEditState_Selected;
            }
            
        }
            break;
        case BbPatchViewEditState_Selected:
        {
            if ( nil == selected || !selected.count ) {
                self.editState = BbPatchViewEditState_Editing;
            }
        }
        default:
            break;
    }
}

- (void)deleteConnectionsIfNeeded
{
    id<BbConnectionPath> toRemove = nil;
    
    for (id<BbConnectionPath> aPath in self.childConnectionPaths.allObjects ) {
        UIBezierPath *path = [aPath bezierPath];
        if ( [self bezierPath:path containsPoint:self.gesture.location] ) {
            toRemove = aPath;
            break;
        }
    }
    
    if ( nil != toRemove ) {
        [self removeConnectionPath:toRemove];
        [self.entity patchView:self didRemoveChildConnection:toRemove.entity];
    }
}

- (void)resetGestureStateConditions
{
    self.activeInlet = nil;
    self.activeObject = nil;
    self.activeOutlet = nil;
    
    if ( self.longPressTimer.isValid ) {
        [self.longPressTimer invalidate];
    }
    
    [self.activePath removeAllPoints];
    self.activePath = nil;
    [self updateAppearance];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( nil != self.activeObject || nil != self.activeOutlet ) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - Accessors

- (void)setEditState:(BbPatchViewEditState)editState
{
    _editState = editState;
    [self.editingDelegate patchView:self didChangeEditState:editState];
    if ( editState == BbPatchViewEditState_Default ) {
        NSArray *toDeselect = [self getSelectedObjects];
        for (id<BbObjectView> anObjectView in toDeselect ) {
            anObjectView.selected = NO;
        }
    }
}

- (void)setActiveInlet:(id<BbEntityView>)activeInlet
{
    if ( !activeInlet || activeInlet != _activeInlet ) {
        _activeInlet.selected = NO;
    }
    
    _activeInlet = activeInlet;
    _activeInlet.selected = YES;
}

- (void)setActiveOutlet:(id<BbEntityView>)activeOutlet
{
    if ( !activeOutlet || activeOutlet != _activeOutlet ) {
        _activeOutlet.selected = NO;
    }
    _activeOutlet = activeOutlet;
    _activeOutlet.selected = YES;
}

- (NSArray *)getSelectedObjects
{
    NSArray *children = self.childObjectViews.allObjects;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    return [children filteredArrayUsingPredicate:pred];
}

#pragma mark - ChildViews

- (void)addPlaceholderObjectView
{
    CGPoint loc = self.gesture.location;
    CGPoint myLoc = [self convertPoint:loc fromView:self.gesture.view];
    myLoc.x /= self.scrollView.zoomScale;
    myLoc.y /= self.scrollView.zoomScale;
    
    id <BbObjectView> placeholder = [[BbPlaceholderView alloc]initWithPosition:[NSValue valueWithCGPoint:self.gesture.position]];
    [self addChildEntityView:placeholder];
    [placeholder updateAppearance];
    self.editingObjectView = placeholder;
    [self.entity patchView:self didAddPlaceholderObjectView:placeholder];
    [self updateAppearance];
}

- (void)moveObjectView:(id)objectView WithDelta:(CGPoint)delta
{
    
    CGRect frame = [(UIView *)objectView frame];
    CGRect newFrame = CGRectOffset(frame, delta.x, delta.y);
    if ( !CGRectContainsRect(self.bounds, newFrame) ) {
        [self resizeIfNeeded];
        return;
    }
    
    BbAbstractView *view = (BbAbstractView *)objectView;
    CGPoint position = view.position.CGPointValue;
    CGPoint point = [self myPosition2Point:position];
    point.x+=delta.x;
    point.y+=delta.y;
    
    CGPoint offsets = [self point2ConstraintOffsets:point];
    view.centerXConstraint.constant = offsets.x;
    view.centerYConstraint.constant = offsets.y;
    [self setNeedsLayout];
    CGPoint newPosition = [self myPoint2Position:point];
    [view positionDidChange:[NSValue valueWithCGPoint:newPosition]];
}

- (void)moveSelectedObjectViewsWithDelta:(CGPoint)delta
{
    if ( self.editState == BbPatchViewEditState_Default ) {
        if ( self.activeObject ) {
            [self moveObjectView:self.activeObject WithDelta:delta];
        }
    }else{
        NSArray *selected = [self getSelectedObjects];
        if ( selected ) {
            for (id<BbObjectView> objectView in selected ) {
                [self moveObjectView:objectView WithDelta:delta];
            }
        }
    }
    
    [self updateAppearance];
}

- (CGPoint)point2ConstraintOffsets:(CGPoint)point
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGFloat xoffset = round(point.x-center.x);
    CGFloat yoffset = round(point.y-center.y);
    return CGPointMake(xoffset, yoffset);
}

- (CGPoint)myPoint2Position:(CGPoint)point
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds));
    CGPoint offset = CGPointMake((point.x-center.x), (point.y-center.y));
    CGPoint position = CGPointMake((offset.x/center.x), (offset.y/center.y));
    return position;
}

- (CGPoint)myPosition2Point:(CGPoint)position
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    CGPoint offset = CGPointMake( (position.x * center.x ),( position.y * center.y ) );
    CGPoint point  = CGPointMake( (center.x + offset.x) , (center.y + offset.y));
    return point;
}

- (BOOL)childViewsNeedAppearanceUpdate
{
    if ( self.childEntityViewQueue.allObjects.count || self.childConnectionQueue.allObjects.count ) {
        return YES;
    }
    
    return NO;
}

- (void)updateChildViewAppearance
{
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    if ( self.childEntityViewQueue.allObjects.count ) {
        for (id<BbObjectView> objectView in self.childEntityViewQueue.allObjects ) {
            [self addChildEntityView:objectView];
            [objectView updateAppearance];
        }
    }
    
    [self.childEntityViewQueue removeAllObjects];
    
    if (self.childConnectionQueue.allObjects.count ){
        for (id<BbConnectionPath> path in self.childConnectionQueue.allObjects ) {
            [self addConnectionPath:path];
            [path updatePath];
        }
    }
    
    [self.childConnectionQueue removeAllObjects];
    [self updateAppearance];
}


- (void)addChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView || [self.childObjectViews containsObject:entityView] ) {
        return;
    }
    
    if ( CGRectIsEmpty(self.bounds) ) {
        [self.childEntityViewQueue addObject:entityView];
        return;
    }
    
    
    [self.childObjectViews addObject:entityView];
    [self addSubview:(UIView *)entityView];
    BbAbstractView *view = (BbAbstractView *)entityView;
    CGPoint pos = view.position.CGPointValue;
    CGPoint pt = [self myPosition2Point:pos];
    CGPoint offsets = [self point2ConstraintOffsets:pt];
    view.centerXConstraint = [view alignCenterXToSuperOffset:offsets.x];
    view.centerYConstraint = [view alignCenterYToSuperOffset:offsets.y];
    [self addConstraint:view.centerXConstraint];
    [self addConstraint:view.centerYConstraint];
    [self setNeedsLayout];
    
    CGRect frame = view.frame;
    if ( !CGRectContainsRect(self.bounds, frame) ) {
        [self resizeIfNeeded];
    }
}

- (void)removeChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView || ![self.childObjectViews containsObject:entityView] ) {
        return;
    }
    [self.childObjectViews removeObject:entityView];
    BbAbstractView *view = (BbAbstractView *)entityView;
    if ( view.centerXConstraint && [self.constraints containsObject:view.centerXConstraint] ) {
        [self removeConstraint:view.centerXConstraint];
    }
    if ( view.centerYConstraint && [self.constraints containsObject:view.centerYConstraint] ) {
        [self removeConstraint:view.centerYConstraint];
    }
    [(UIView *)entityView removeFromSuperview];
    
}

#pragma mark - Connections

- (void)addConnectionPath:(id<BbConnectionPath>)path
{
    if ( [self.childConnectionPaths containsObject:path] ) {
        return;
    }
    
    if ( CGRectIsEmpty(self.bounds) ) {
        [self.childConnectionQueue addObject:path];
        return;
    }
    
    [self.childConnectionPaths addObject:path];
    [self updateAppearance];
}

- (void)removeConnectionPath:(id<BbConnectionPath>)path
{
    if ( ![self.childConnectionPaths containsObject:path] ) {
        return;
    }
    
    [self.childConnectionPaths removeObject:path];
    [self updateAppearance];
}

- (CGPoint)connectionOrigin
{
    if ( !self.activeOutlet ) {
        return CGPointZero;
    }
    CGPoint origin = [self convertPoint:[(UIView *)self.activeOutlet center] fromView:[(UIView *)self.activeOutlet superview]];
    return origin;
}


- (void)updateAppearance
{
    if ( [self childViewsNeedAppearanceUpdate] ) {
        [self updateChildViewAppearance];
        [self resizeIfNeeded];
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ( nil != self.activeOutlet ) {
        [[UIColor blackColor]setStroke];
        CGPoint connectionOrigin = [self connectionOrigin];
        self.activePath = [UIBezierPath bezierPath];
        self.activePath.lineWidth = 8;
        [self.activePath moveToPoint:connectionOrigin];
        [self.activePath addLineToPoint:self.gesture.location];
        [self.activePath stroke];
    }
    
    if ( self.childConnectionPaths.allObjects ) {
        
        for (id<BbConnectionPath> aPath in self.childConnectionPaths.allObjects ) {
            [aPath updatePath];
            UIBezierPath *bezierPath = [aPath bezierPath];
            [bezierPath setLineWidth:6];
            if ( aPath.isSelected ) {
                [[UIColor colorWithWhite:0.4 alpha:1] setStroke];
            }else{
                [[UIColor blackColor]setStroke];
            }
            [bezierPath stroke];
            
        }
    }
}

- (void)resizeIfNeeded
{
    CGRect bounds = self.bounds;
    CGPoint oldOrigin = bounds.origin;
    CGPoint newOrigin = oldOrigin;
    CGPoint oldMax = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    CGPoint newMax = oldMax;
    
    for (id<BbObjectView> childView in self.childObjectViews.allObjects ) {
        CGRect childRect = [(UIView *)childView frame];
        if ( !CGRectContainsRect(bounds, childRect) ) {
            CGPoint childOrigin = childRect.origin;
            CGPoint childMax = CGPointMake(CGRectGetMaxX(childRect), CGRectGetMaxY(childRect));
            if ( newOrigin.x > childOrigin.x ) {
                newOrigin.x = childOrigin.x;
            }
            
            if ( newOrigin.y > childOrigin.y ) {
                newOrigin.y = childOrigin.y;
            }
            
            if ( newMax.x < childMax.x ) {
                newMax.x = childMax.x;
            }
            
            if ( newMax.y < childMax.y ) {
                newMax.y = childMax.y;
            }
        }
    }

    if ( !CGRectContainsPoint(bounds, newOrigin) || !CGRectContainsPoint(bounds, newMax) ) {
        CGSize newSize = CGSizeMake(newMax.x-newOrigin.x, newMax.y-newOrigin.y);
        CGSize superviewSize = self.superview.bounds.size;
        CGSize newSizeScale = CGSizeMake(newSize.width/superviewSize.width, newSize.height/superviewSize.height);
        if ( newSizeScale.width > 2.0 && newSizeScale.height > 2.0 ) {
            [self.entity objectView:self didChangeValue:[NSValue valueWithCGSize:newSizeScale] forViewArgumentKey:kViewArgumentKeySize];
            [self.editingDelegate patchView:self didEditValue:[NSValue valueWithCGSize:newSizeScale] forViewArgumentKey:kViewArgumentKeySize];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateAppearance];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ( !decelerate ) {
        CGRect bounds = self.bounds;
        CGPoint offset = scrollView.contentOffset;
        CGPoint myOffset;
        myOffset.x = (offset.x/CGRectGetWidth(bounds));
        myOffset.y = (offset.y/CGRectGetHeight(bounds));
        [self.entity objectView:self didChangeValue:[NSValue valueWithCGPoint:myOffset] forViewArgumentKey:kViewArgumentKeyContentOffset];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGRect bounds = self.bounds;
    CGPoint offset = scrollView.contentOffset;
    CGPoint myOffset;
    myOffset.x = (offset.x/CGRectGetWidth(bounds));
    myOffset.y = (offset.y/CGRectGetHeight(bounds));
    [self.entity objectView:self didChangeValue:[NSValue valueWithCGPoint:myOffset] forViewArgumentKey:kViewArgumentKeyContentOffset];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.entity objectView:self didChangeValue:@(scale) forViewArgumentKey:kViewArgumentKeyZoomScale];
}


@end
