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

- (void)setScrollView:(BbScrollView *)scrollView
{
    _scrollView = scrollView;
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
    self.scrollView.contentOffset = offset.CGPointValue;
    NSValue *zoom = [BbHelpers zoomScaleFromViewArgs:viewArguments];
    self.scrollView.zoomScale = [(NSNumber *)zoom doubleValue];
    self.scrollView.delegate = self;
    [self updateChildViewAppearance];
}

- (void)updateChildViewAppearance
{
    for (id<BbObjectView> aChildView  in self.childObjectViews.allObjects ) {
        [aChildView moveToPosition:aChildView.position];
    }
    
    [self updateAppearance];
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
                    if ( gesture.currentView.isSelected ) {
                        [gesture.currentView setSelected:NO];
                    }else{
                        [gesture.currentView setSelected:YES];
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
                        case BbPatchViewEditState_Editing:
                        case BbPatchViewEditState_Selected:
                        case BbPatchViewEditState_Copied:

                            break;
                            
                        default:
                        {
                            if ( nil == self.selectedObject ) {
                                [gesture stopTracking];
                                return;
                            }else{
                                    CGPoint point = [(UIView *)gesture.firstView center];
                                    point.x+=gesture.deltaLocation.x;
                                    point.y+=gesture.deltaLocation.y;
                                    [gesture.firstView moveToPoint:[NSValue valueWithCGPoint:point]];
                                    [self updateAppearance];
                            }
                        }
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
                    BOOL updateSelected = NO;
                    for (id<BbConnectionPath> aConnection in self.childConnectionPaths.allObjects ) {
                        UIBezierPath *path = [aConnection bezierPath];
                        if ( [self bezierPath:path containsPoint:gesture.location] ) {
                            if ( aConnection.isSelected ) {
                                [aConnection setSelected:NO];
                            }else{
                                [aConnection setSelected:YES];
                            }
                            updateSelected = YES;
                        }
                    }
                    
                    if ( updateSelected ) {
                        NSArray *selectedConnections = [self getSelectedConnections];
                        if ( nil != selectedConnections && selectedConnections.count ) {
                            if ( self.editState == BbPatchViewEditState_Editing ) {
                                self.editState = BbPatchViewEditState_Selected;
                            }
                        }else{
                            if ( self.editState == BbPatchViewEditState_Selected ) {
                                self.editState = BbPatchViewEditState_Default;
                            }
                        }
                    }
                    
                }
                    break;
                    
                default:
                {
                    if ( gesture.repeatCount && gesture.movement < kMaxMovement ) {
                        // add box
                        id <BbObjectView> placeholder = [BbView viewWithEntity:nil];
                        [self addChildEntityView:placeholder];
                        [placeholder moveToPoint:[NSValue valueWithCGPoint:gesture.location]];
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

- (NSArray *)getSelectedConnections
{
    NSArray *connections = self.childConnectionPaths.allObjects;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    return [connections filteredArrayUsingPredicate:pred];
}

#pragma mark - ChildViews

- (void)addChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView ) {
        return;
    }
    
    [self.childObjectViews addObject:entityView];
    [self addSubview:(UIView *)entityView];
    NSArray *constraints = [(id<BbObjectView>)entityView positionConstraints];
    if ( nil != constraints ) {
        [self addConstraints:constraints];
    }
}

- (void)removeChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView ) {
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
    if ( self.childConnectionPaths.allObjects ) {
        
        for (id<BbConnectionPath> aPath in self.childConnectionPaths.allObjects ) {
            
            UIBezierPath *bezierPath = [aPath bezierPath];
            [bezierPath setLineWidth:6];
            [[UIColor blackColor]setStroke];
            [bezierPath stroke];
            
        }
    }
    
    if ( nil != self.activePath ) {
        self.activePath.lineWidth = 8;
        [self.activePath stroke];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSString *viewArgs = self.entity.viewArguments;
    CGSize mySize = scrollView.contentSize;
    CGPoint myCenter = CGPointMake(mySize.width/2, mySize.height/2);
    CGSize myOffset;
    myOffset.width = (scrollView.contentOffset.x-myCenter.x)/(mySize.width/2);
    myOffset.height = (scrollView.contentOffset.y-myCenter.y)/(mySize.height/2);
    viewArgs = [viewArgs setArgument:@(myOffset.width) atIndex:kViewArgumentIndexContentOffset_X];
    viewArgs = [viewArgs setArgument:@(myOffset.height) atIndex:kViewArgumentIndexContentOffset_Y];
    self.entity.viewArguments = viewArgs;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    NSString *viewArgs = self.entity.viewArguments;
    viewArgs = [viewArgs setArgument:@(scale) atIndex:kViewArgumentIndexZoomScale];
}

@end
