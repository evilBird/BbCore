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

static NSTimeInterval       kLongPressMinDuration = 0.5;
static CGFloat              kMaxMovement          = 20.0;

@interface BbPatchView () <UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)        UIBezierPath                        *activePath;

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

- (void)setEditState:(BbPatchViewEditState)editState
{
    BbPatchViewEditState prevState = _editState;
    _editState = editState;
    [self.editingDelegate patchView:self didChangeEditState:editState];
    if ( editState != prevState ) {
        if ( editState == BbPatchViewEditState_Default ) {
            NSArray *toDeselect = [self getSelectedObjects];
            for (id<BbObjectView> anObjectView in toDeselect ) {
                anObjectView.selected = NO;
            }
        }
    }
}

- (void)commonInit
{
    self.gesture = [[BbPatchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    self.gesture.cancelsTouchesInView = NO;
    self.gesture.delaysTouchesBegan = YES;
    self.gesture.delaysTouchesEnded = YES;
    self.gesture.delegate = self;
    [self addGestureRecognizer:self.gesture];
    self.childObjectViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.childConnectionPaths = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.entityViewType = BbEntityViewType_Patch;
}

- (void)layoutWithScrollView:(BbScrollView *)scrollView
{
    self.scrollView = scrollView;
    [self configureScrollView];
}

- (void)configureScrollView
{
    CGRect myFrame = self.scrollView.bounds;
    NSString *viewArguments = self.entity.viewArguments;
    NSValue *size = [BbHelpers sizeFromViewArgs:viewArguments];
    CGSize sizeScale = size.CGSizeValue;
    
    if ( sizeScale.width > 2 ) {
        sizeScale.width = 2;
    }
    if ( sizeScale.height > 2 ) {
        sizeScale.height = 2;
    }
    
    CGSize mySize = [self multiplySize:self.scrollView.bounds.size withSize:sizeScale];
    myFrame.size = mySize;
    myFrame.origin = CGPointZero;
    self.frame = myFrame;
    [self.scrollView addSubview:self];
    self.scrollView.contentSize = mySize;
    NSValue *offset = [BbHelpers offsetFromViewArgs:viewArguments];
    CGPoint o = offset.CGPointValue;
    CGPoint scaledOffset;
    scaledOffset.x = (myFrame.size.width * o.x);
    scaledOffset.y = (myFrame.size.height * o.y);
    self.scrollView.contentOffset = scaledOffset;
    NSValue *zoom = [BbHelpers zoomScaleFromViewArgs:viewArguments];
    self.scrollView.delegate = self;
    self.scrollView.zoomScale = [(NSNumber *)zoom doubleValue];
    [self updateChildViewAppearance];
}

- (void)updateChildViewAppearance
{
    for (id<BbObjectView> aChildView  in self.childObjectViews.allObjects ) {
        [aChildView moveToPosition:aChildView.position];
    }
    
    for (id<BbConnectionPath> aPath in self.childConnectionPaths ) {
        [aPath updatePath];
    }
    
    [self updateAppearance];
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

- (void)handleGesture:(BbPatchGestureRecognizer *)gesture
{
    if ( gesture.state == UIGestureRecognizerStateCancelled ) {
        [self resetGestureStateConditions];
    }else if ( gesture.numberOfTouches > 1 ){
        [self.gesture stopTracking];
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
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

- (void)handleGestureBegan:(BbPatchGestureRecognizer *)gesture
{
    switch (gesture.currentViewType) {
        
        case BbEntityViewType_Object:
        {
            if (gesture.currentView.isEditing) {
                [gesture stopTracking];
                return;
            }
            
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                    if ( [gesture.currentView isSelected] ) {
                        [gesture.currentView setSelected:NO];
                    }else{
                        [gesture.currentView setSelected:YES];
                    }
                }
                    break;
                    
                default:
                {
                    self.scrollView.touchesShouldBegin = NO;
                    self.selectedObject = gesture.currentView;
                }
                    break;
            }
            //Select view and prepare to pan or move

        }
            break;
        case BbEntityViewType_Outlet:
        {
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                    [gesture stopTracking];
                    return;
                }
                    break;
                    
                default:
                {
                    //Select outlet and prepare to draw connection
                    self.scrollView.touchesShouldBegin = NO;
                    self.selectedOutlet = gesture.currentView;
                }
                    break;
            }
            
        }
            break;
        case BbEntityViewType_Control:
        {
            self.scrollView.touchesShouldBegin = NO;
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                    NSUInteger numSelected = [self getSelectedObjects].count;
                    NSUInteger prevNum = numSelected;
                    if ( gesture.currentView.isSelected ) {
                        
                        [gesture.currentView setSelected:NO];
                        numSelected--;
                        
                    }else{
                        
                        [gesture.currentView setSelected:YES];
                        numSelected++;
                    }
                    
                    if ( numSelected && !prevNum ) {
                        self.editState = BbPatchViewEditState_Selected;
                    }else if ( prevNum && !numSelected ){
                        self.editState = BbPatchViewEditState_Editing;
                    }
                    
                }
                    break;
                    
                default:
                {
                    if ( ! gesture.currentView.isEditing ){
                        [(id<BbObject>)[gesture.currentView entity] sendActionsForView:gesture.currentView];
                        self.selectedObject = gesture.currentView;
                    }
                }
                    break;
            }
        }
            break;
        case BbEntityViewType_Patch:
        {
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                }
                    break;
                    
                default:
                {
                    if ( !gesture.repeatCount ) {
                        [gesture stopTracking];
                        self.scrollView.touchesShouldBegin = YES;
                    }
                }
                    break;
            }
        }
            break;
        default:
        {
            [gesture stopTracking];
            self.scrollView.touchesShouldBegin = YES;
        }
            break;
    }

}

- (void)moveSelectedObjectViewsWithDelta:(CGPoint)delta
{
    NSArray *selectedObjectViews = [self getSelectedObjects];
    if ( !selectedObjectViews.count ) {
        return;
    }
    for (id<BbObjectView> objectView in selectedObjectViews ) {
        CGPoint position = objectView.position.CGPointValue;
        CGPoint posPoint = [(UIView *)objectView position2Point:position];
        posPoint.x+=delta.x;
        posPoint.y+=delta.y;
        [objectView moveToPoint:[NSValue valueWithCGPoint:posPoint]];
    }
    
    [self updateAppearance];
}

- (void)handleGestureMoved:(BbPatchGestureRecognizer *)gesture
{
    switch (gesture.currentViewType) {
            
        case BbEntityViewType_Inlet:
        {
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                    
                }
                    break;
                    
                default:
                {
                    if ( nil != self.selectedOutlet ) {
                        self.selectedInlet = gesture.currentView;
                        [self updateAppearance];
                    }
                }
                    break;
            }
        }
            break;
            
        default:
            
            self.selectedInlet = nil;
            
            switch (gesture.firstViewType) {
                case BbEntityViewType_Control:
                case BbEntityViewType_Object:
                {
                    switch ( self.editState ) {
                        case BbPatchViewEditState_Selected:
                        case BbPatchViewEditState_Copied:
                        {
                            [self moveSelectedObjectViewsWithDelta:gesture.deltaLocation];
                        }
                            break;
                            
                        case BbPatchViewEditState_Default:
                        case BbPatchViewEditState_Editing:
                        {
                            if ( nil == self.selectedObject ) {
                                [gesture stopTracking];
                                return;
                            }else{
                                CGPoint position = gesture.firstView.position.CGPointValue;
                                CGPoint posPoint = [(UIView *)gesture.firstView position2Point:position];
                                posPoint.x+=gesture.deltaLocation.x;
                                posPoint.y+=gesture.deltaLocation.y;
                                [gesture.firstView moveToPoint:[NSValue valueWithCGPoint:posPoint]];
                                [self updateAppearance];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case BbEntityViewType_Outlet:
                {
                    switch ( self.editState ) {
                        case BbPatchViewEditState_Editing:
                        case BbPatchViewEditState_Selected:
                        case BbPatchViewEditState_Copied:
                        {
                            
                        }
                            break;
                            
                        default:
                        {
                            [self updateAppearance];
                        }
                            break;
                    }
                }
                    break;
                case BbEntityViewType_Patch:
                {
                    
                }
                    
                default:
                    
                    break;
            }
            
            break;
    }
}

- (void)handleGestureEnded:(BbPatchGestureRecognizer *)gesture
{
    switch ( gesture.currentViewType ) {
            
        case BbEntityViewType_Inlet:
        {
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                    
                }
                    break;
                    
                default:
                {
                    if ( nil != self.selectedInlet && nil != self.selectedOutlet ) {
                        //make connection
                        [(id<BbPatch>)self.entity patchView:self didConnectOutletView:self.selectedOutlet toInletView:self.selectedInlet];
                    }
                }
                    break;
            }
        }
            break;
        case BbEntityViewType_Patch:
        {
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                case BbPatchViewEditState_Selected:
                case BbPatchViewEditState_Copied:
                {
                    id<BbConnectionPath> toRemove = nil;
                    
                    for (id<BbConnectionPath> aPath in self.childConnectionPaths.allObjects ) {
                        UIBezierPath *path = [aPath bezierPath];
                        if ( [self bezierPath:path containsPoint:gesture.location] ) {
                            toRemove = aPath;
                            break;
                        }
                    }
                    
                    if ( nil != toRemove ) {
                        [self removeConnectionPath:toRemove];
                        [self.entity patchView:self didRemoveChildConnection:toRemove.entity];
                    }
                    
                }
                    break;
                    
                default:
                {
                    if ( gesture.repeatCount && gesture.movement < kMaxMovement ) {
                        // add box
                        id <BbObjectView> placeholder = [BbView viewWithEntity:nil];
                        NSValue *position = [NSValue valueWithCGPoint:gesture.position];
                        placeholder.position = position;
                        [self addChildEntityView:placeholder];
                        [self.entity patchView:self didAddPlaceholderObjectView:placeholder];
                        
                        NSLog(@"\nzoom = %.3f...location = (%.2f, %.2f)...position = (%.3f, %.3f)\n",self.scrollView.zoomScale,gesture.location.x,gesture.location.y,gesture.position.x,gesture.position.y);
                    }
                }
                    break;
            }
        }
            break;
        case BbEntityViewType_Object:
        case BbEntityViewType_Control:
        {
            switch ( self.editState ) {
                case BbPatchViewEditState_Editing:
                {
                    NSArray *selected = [self getSelectedObjects];
                    if ( nil != selected && selected.count ) {
                        self.editState = BbPatchViewEditState_Selected;
                    }
                    
                }
                    break;
                case BbPatchViewEditState_Selected:
                {
                    NSArray *selected = [self getSelectedObjects];
                    if ( nil == selected || !selected.count ) {
                        self.editState = BbPatchViewEditState_Editing;
                    }
                }
                case BbPatchViewEditState_Copied:
                {
                    
                }
                    break;
                    
                default:
                {
                    if ( gesture.repeatCount && gesture.movement < kMaxMovement ) {
                        //show box options
                        
                    }else if ( gesture.duration > kLongPressMinDuration  && gesture.movement < kMaxMovement ){
                        //edit box
                        if ( !gesture.currentView.isEditing && [gesture.currentView canEdit] ) {
                            gesture.currentView.editing = YES;
                        }
                    }
                }
                    break;
            }
            
        }
            break;
        default:
            break;
    }
    
    [self resetGestureStateConditions];
}

- (void)resetGestureStateConditions
{
    self.selectedInlet = nil;
    self.selectedOutlet = nil;
    self.selectedObject = nil;
    [self.activePath removeAllPoints];
    self.activePath = nil;
    [self updateAppearance];
}

- (CGPoint)gestureLocToPosition:(CGPoint)loc
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds),CGRectGetMidY(bounds));
    CGPoint offset = CGPointMake((loc.x-center.x), (loc.y-center.y));
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

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( nil != self.selectedObject || nil != self.selectedOutlet ) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - Accessors

- (void)setSelectedObject:(id<BbObjectView>)selectedObject
{
    id<BbObjectView> prevSelObject = _selectedObject;
    _selectedObject = selectedObject;
    if ( nil == _selectedObject ) {
        prevSelObject.selected = NO;
    }else{
        _selectedObject.selected = YES;
        self.scrollView.touchesShouldBegin = NO;
    }
}

- (void)setSelectedInlet:(id<BbEntityView>)selectedInlet
{
    id<BbEntityView> prevSelInlet = _selectedInlet;
    _selectedInlet = selectedInlet;
    if ( nil == _selectedInlet) {
        prevSelInlet.selected = NO;
    }else{
        _selectedInlet.selected = YES;
    }
}

- (void)setSelectedOutlet:(id<BbEntityView>)selectedOutlet
{
    id<BbEntityView> prevSelOutlet = _selectedOutlet;
    _selectedOutlet = selectedOutlet;
    if ( nil == _selectedOutlet ){
        prevSelOutlet.selected = NO;
    }else{
        _selectedOutlet.selected = YES;
        self.scrollView.touchesShouldBegin = NO;
    }
}

- (NSArray *)getSelectedObjects
{
    NSArray *children = self.childObjectViews.allObjects;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    return [children filteredArrayUsingPredicate:pred];
}

#pragma mark - ChildViews

- (void)addChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView || [self.childObjectViews containsObject:entityView] ) {
        return;
    }
    
    [self.childObjectViews addObject:entityView];
    [self addSubview:(UIView *)entityView];
    NSArray *constraints = [(id<BbObjectView>)entityView positionConstraints];
    
    if ( nil != constraints ) {
        [self addConstraints:constraints];
        [self layoutIfNeeded];
    }
}

- (void)removeChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView || ![self.childObjectViews containsObject:entityView] ) {
        return;
    }
    [self.childObjectViews removeObject:entityView];
    NSArray *constraints = [(id<BbObjectView>)entityView positionConstraints];
    if ( nil != constraints ) {
        [self removeConstraints:constraints];
    }
    [(UIView *)entityView removeFromSuperview];
    
}

#pragma mark - Connections

- (void)addConnectionPath:(id<BbConnectionPath>)path
{
    if ( [self.childConnectionPaths containsObject:path] ) {
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
    if ( nil == self.selectedOutlet ) {
        return CGPointZero;
    }
    CGPoint origin = [self convertPoint:[(UIView *)self.selectedOutlet center] fromView:[(UIView *)self.selectedOutlet superview]];
    return origin;
}


- (void)updateAppearance
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if ( nil != self.selectedOutlet ) {
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
