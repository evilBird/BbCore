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

static NSTimeInterval       kLongPressMinDuration = 0.5;
static CGFloat              kMaxMovement          = 20.0;

@interface BbPatchView () <UIGestureRecognizerDelegate>

@property (nonatomic,weak)          id<BbObjectView>                    selectedInlet;
@property (nonatomic,weak)          id<BbObjectView>                    selectedOutlet;
@property (nonatomic,weak)          id<BbObjectView>                    selectedObject;

@property (nonatomic,strong)        BbPatchGestureRecognizer            *gesture;

@property (nonatomic,strong)        UIBezierPath                        *activeConnection;

@end

@implementation BbPatchView

#pragma mark - Constructors

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        _dataSource = dataSource;
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
    self.childViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.connections = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    self.pathConnectionMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
}

- (BbViewType)viewTypeCode
{
    return BbViewType_Patch;
}

- (void)setEditState:(BbObjectViewEditState)editState
{
    BbObjectViewEditState prevState = _editState;
    _editState = editState;
    if ( _editState != prevState ) {
        [self.editingDelegate objectView:self didChangeEditState:_editState];
    }
}

- (void)cutSelected
{
    NSArray *selectedConnections = [self getSelectedConnections];
    if ( nil != selectedConnections ) {
        for (id<BbConnection> aConnection in selectedConnections ) {
            [self.delegate objectView:self didDeleteConnection:aConnection];
        }
    }
    
    NSArray *selectedObjects = [self getSelectedObjects];
    if ( nil != selectedObjects ) {
        for (id <BbObjectView> childObjectView in selectedObjects ) {
            [self.delegate objectView:self didRemoveChildObjectView:childObjectView];
        }
    }
    
}

- (void)copySelected
{
    
}

- (void)abstractCopied
{
    
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
                    [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
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
                    [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
                    self.selectedOutlet = gesture.currentView;
                }
                    break;
            }
            
        }
            break;
        case BbViewType_Control:
        {
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
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
                        [[gesture.currentView delegate]sendActionsForObjectView:gesture.currentView];
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
                        [self.eventDelegate patchView:self setScrollViewShouldBegin:YES];
                    }
                }
                    break;
            }
        }
            break;
        default:
        {
            [gesture stopTracking];
            [self.eventDelegate patchView:self setScrollViewShouldBegin:YES];
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
                                    CGPoint point = gesture.firstView.center;
                                    point.x+=gesture.deltaLocation.x;
                                    point.y+=gesture.deltaLocation.y;
                                    [gesture.firstView moveToPoint:point];
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
                        [self.delegate objectView:self didConnectPortView:self.selectedOutlet toPortView:self.selectedInlet];
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
                    for (id<BbConnection> aConnection in self.connections.allObjects ) {
                        UIBezierPath *path = aConnection.path;
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
                        id <BbObjectView> placeholder = [BbView<BbObjectView> createPlaceholder];
                        [self addChildObjectView:placeholder];
                        [placeholder moveToPoint:gesture.location];
                        [self.delegate objectView:self didAddChildObjectView:placeholder];
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
                        BOOL canOpen = [self.dataSource objectView:self canOpenChildView:gesture.currentView];
                        BOOL canGetHelp = [self.dataSource objectView:self canOpenHelpObjectForChildView:gesture.currentView];
                        BOOL canTest = [self.dataSource objectView:self canTestObjectForChildView:gesture.currentView];
                        
                    }else if ( gesture.duration > kLongPressMinDuration  && gesture.movement < kMaxMovement ){
                        //edit box
                        if ( !gesture.currentView.isEditing && [gesture.currentView canEdit] ) {
                            gesture.currentView.editingDelegate = (id<BbObjectViewEditingDelegate>)self.delegate;
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
    [self.activeConnection removeAllPoints];
    self.activeConnection = nil;
    [self setNeedsDisplay];
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
        [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
    }
}

- (void)setSelectedInlet:(id<BbObjectView>)selectedInlet
{
    id<BbObjectView> prevSelInlet = _selectedInlet;
    _selectedInlet = selectedInlet;
    if ( nil == _selectedInlet) {
        prevSelInlet.selected = NO;
    }else{
        _selectedInlet.selected = YES;
    }
}

- (void)setSelectedOutlet:(id<BbObjectView>)selectedOutlet
{
    id<BbObjectView> prevSelOutlet = _selectedOutlet;
    _selectedOutlet = selectedOutlet;
    if ( nil == _selectedOutlet ){
        prevSelOutlet.selected = NO;
    }else{
        _selectedOutlet.selected = YES;
        [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
    }
}

- (NSArray *)getSelectedObjects
{
    NSArray *children = self.childViews.allObjects;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    return [children filteredArrayUsingPredicate:pred];
}

- (NSArray *)getSelectedConnections
{
    NSArray *connections = self.connections.allObjects;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == 1",@"selected"];
    return [connections filteredArrayUsingPredicate:pred];
}

#pragma mark - Connections

- (void)addConnection:(id<BbConnection>)connection
{
    if ( [self.connections containsObject:connection] ) {
        return;
    }
    [self.connections addObject:connection];
    [self updateAppearance];
}

- (void)removeConnection:(id<BbConnection>)connection
{
    if ( ![self.connections containsObject:connection] ) {
        return;
    }
    
    [self.connections removeObject:connection];
    [self updateAppearance];
}

- (CGPoint)connectionOrigin
{
    if ( nil == self.selectedOutlet ) {
        return CGPointZero;
    }
    CGPoint origin = [self convertPoint:self.selectedOutlet.center fromView:self.selectedOutlet.superview];
    return origin;
}

- (void)updateAppearance
{
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ( nil != self.selectedOutlet ) {
        [[UIColor blackColor]setStroke];
        CGPoint connectionOrigin = [self connectionOrigin];
        self.activeConnection = [UIBezierPath bezierPath];
        self.activeConnection.lineWidth = 8;
        [self.activeConnection moveToPoint:connectionOrigin];
        [self.activeConnection addLineToPoint:self.gesture.location];
        [self.activeConnection stroke];
    }
    
    if ( self.connections.allObjects.count ) {        
        for (id<BbConnection> connection in self.connections ) {
            if (nil != [connection inletView] && nil != [connection outletView] ){
                CGPoint origin = [self convertPoint:[connection outletView].center fromView:[connection outletView].superview];
                CGPoint terminus = [self convertPoint:[connection inletView].center fromView:[connection inletView].superview];
                UIBezierPath *path = [UIBezierPath bezierPath];
                [path moveToPoint:origin];
                [path addLineToPoint:terminus];
                [path setLineWidth:[connection strokeWidth]];
                [[connection strokeColor] setStroke];
                [path stroke];
                connection.path = path;
            }
        }
        
       // [self.connectionPathsToRedraw removeAllObjects];
    }
}


@end
