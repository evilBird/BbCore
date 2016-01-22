//
//  BbPatchView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbPatchView.h"
#import "BbView.h"
#import "BbPortView.h"
#import "UIView+BbPatch.h"
#import "BbPatchGestureRecognizer.h"
#import "BbPatchContentView.h"

static NSTimeInterval       kLongPressMinDuration = 0.5;
static CGFloat              kMaxMovement          = 20.0;

@interface BbPatchView () <UIGestureRecognizerDelegate>

@property (nonatomic,strong)        BbPatchGestureRecognizer            *gesture;
@property (nonatomic,strong)        BbPatchContentView                  *patchContentView;
//@property (nonatomic,strong)        UIBezierPath                        *activeConnection;

@end

@implementation BbPatchView

#pragma mark - Constructors

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
    [self setupScrollView];
    [self setupPatchContentView];
    
    self.gesture = [[BbPatchGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    self.gesture.cancelsTouchesInView = NO;
    self.gesture.delaysTouchesBegan = YES;
    self.gesture.delaysTouchesEnded = YES;
    self.gesture.delegate = self;
    [self.patchContentView addGestureRecognizer:self.gesture];
    self.childObjectViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.childConnectionPaths = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.entityViewType = BbEntityViewType_Patch;
}

- (void)setupScrollView
{
    self.scrollView = [[BbScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.backgroundColor = [UIColor greenColor];
    [self addSubview:self.scrollView];
    [self addConstraints:[self.scrollView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
}

- (void)setupPatchContentView
{
    self.patchContentView = [BbPatchContentView new];
    self.patchContentView.backgroundColor = [UIColor yellowColor];
    NSString *viewArguments = self.entity.viewArguments;
    CGSize sizeFactor = [BbHelpers sizeFromViewArgs:viewArguments].CGSizeValue;
    CGRect bounds = self.bounds;
    bounds.size = [self multiplySize:bounds.size withSize:sizeFactor];
    self.patchContentView.frame = bounds;
    [self.scrollView addSubview:self.patchContentView];
    self.scrollView.contentSize = self.patchContentView.bounds.size;
    self.scrollView.zoomScale = [(NSNumber *)[BbHelpers zoomScaleFromViewArgs:viewArguments]doubleValue];
    CGPoint offsetFactor = [BbHelpers offsetFromViewArgs:viewArguments].CGPointValue;
    offsetFactor.x *= self.patchContentView.bounds.size.width;
    offsetFactor.y *= self.patchContentView.bounds.size.height;
    self.scrollView.contentOffset = offsetFactor;
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
        
        case BbViewType_Object:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
        case BbViewType_Outlet:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
        case BbViewType_Control:
        {
            self.scrollView.touchesShouldBegin = NO;
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
                        [[gesture.currentView entity] sendActionsForView:gesture.currentView];
                        self.selectedObject = gesture.currentView;
                    }
                }
                    break;
            }
        }
            break;
        case BbViewType_Patch:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
            
        case BbViewType_Inlet:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
                case BbViewType_Control:
                case BbViewType_Object:
                {
                    switch ( self.editState ) {
                        case BbObjectViewEditState_Editing:
                        case BbObjectViewEditState_Selected:
                        case BbObjectViewEditState_Copied:

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
                case BbViewType_Outlet:
                {
                    switch ( self.editState ) {
                        case BbObjectViewEditState_Editing:
                        case BbObjectViewEditState_Selected:
                        case BbObjectViewEditState_Copied:
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
                case BbViewType_Patch:
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
            
        case BbViewType_Inlet:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
        case BbViewType_Patch:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                case BbObjectViewEditState_Selected:
                case BbObjectViewEditState_Copied:
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
                            if ( self.editState == BbObjectViewEditState_Editing ) {
                                self.editState = BbObjectViewEditState_Selected;
                            }
                        }else{
                            if ( self.editState == BbObjectViewEditState_Selected ) {
                                self.editState = BbObjectViewEditState_Default;
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
        case BbViewType_Object:
        case BbViewType_Control:
        {
            switch ( self.editState ) {
                case BbObjectViewEditState_Editing:
                {
                    NSArray *selected = [self getSelectedObjects];
                    if ( nil != selected && selected.count ) {
                        self.editState = BbObjectViewEditState_Selected;
                    }
                    
                }
                    break;
                case BbObjectViewEditState_Selected:
                {
                    NSArray *selected = [self getSelectedObjects];
                    if ( nil == selected || !selected.count ) {
                        self.editState = BbObjectViewEditState_Editing;
                    }
                }
                case BbObjectViewEditState_Copied:
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
    [self.patchContentView.activePath removeAllPoints];
    self.patchContentView = nil;
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
    [self.patchContentView drawConnectionPaths:self.childConnectionPaths.allObjects];
}

@end
