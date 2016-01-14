//
//  BbPatchView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbPatchView.h"
#import "BbBoxView.h"
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

@property (nonatomic,strong)        NSArray                             *viewTypes;

@property (nonatomic)               BbPatchViewType                     firstViewType;
@property (nonatomic)               BbPatchViewType                     currentViewType;
@property (nonatomic)               BbPatchViewType                     lastViewType;

@property (nonatomic,strong)        UIBezierPath                        *activeConnection;

@property (nonatomic)               NSUInteger                          hasSelectedObject;
@property (nonatomic)               NSUInteger                          hasSelectedOutlet;
@property (nonatomic)               NSUInteger                          hasSelectedInlet;


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
    self.currentViewType = [self viewType:gesture.firstView];
    self.firstViewType = self.currentViewType;
    BOOL isEditing = ( self.editState > BbObjectViewEditState_Default );
    id<BbObjectView> objectView = (id<BbObjectView>)gesture.firstView;
    
    switch (self.firstViewType) {
        
        case BbPatchViewType_Object:
        case BbPatchViewType_ObjectSubview:
        {
            //Select view and prepare to pan or move
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
            UIView *first = gesture.firstView;
            self.selectedObject = ( self.firstViewType == BbPatchViewType_Object ) ? (BbBoxView *)first : (BbBoxView *)first.superview;
        }
            break;
        case BbPatchViewType_Outlet:
        {
            if ( isEditing ) {
                [gesture stopTracking];
                return;
            }
            //Select outlet and prepare to draw connection
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
            self.selectedOutlet = (BbOutletView *)gesture.firstView;
            
        }
            break;
        case BbPatchViewType_ActionObject:
        {
            [self.eventDelegate patchView:self setScrollViewShouldBegin:NO];
            if ( isEditing ) {
                //send object actions
                [[objectView delegate]sendActionsForObjectView:objectView];
            }
        }
            break;
        case BbPatchViewType_Patch:
        {
            if ( !gesture.repeatCount ) {
                [gesture stopTracking];
                [self.eventDelegate patchView:self setScrollViewShouldBegin:YES];
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
    self.currentViewType = [self viewType:gesture.currentView];
    BOOL isEditing = ( self.editState > BbObjectViewEditState_Default );
    id<BbObjectView> objectView = (id<BbObjectView>)gesture.currentView;
    switch (self.currentViewType) {
            
        case BbPatchViewType_Inlet:
        {
            if ( !isEditing && nil != self.selectedOutlet ) {
                self.selectedInlet = (BbInletView *)gesture.currentView;
                [self setNeedsDisplay];
            }
        }
            break;
            
        default:
            
            self.selectedInlet = nil;
            
            switch (self.firstViewType) {
                case BbPatchViewType_Object:
                {
                    if ( !isEditing && !self.hasSelectedObject ) {
                        [gesture stopTracking];
                        return;
                    }
                    if ( isEditing ) {
                        NSArray *selected = [self getSelectedObjects];
                        //Move selected
                    }else if ( self.hasSelectedObject ){
                        CGPoint point = objectView.center;
                        point.x+=gesture.deltaPosition.x;
                        point.y+=gesture.deltaPosition.y;
                        [objectView moveToPoint:point];
                        [self setNeedsDisplay];
                    }
                }
                    break;
                case BbPatchViewType_Outlet:
                {
                    if ( !isEditing ) {
                        //Draw connection
                        [self setNeedsDisplay];
                    }
                }
                    break;
                    
                default:
                    
                    break;
            }
            
            break;
    }
}

- (void)handleGestureEnded:(BbPatchGestureRecognizer *)gesture
{
    self.currentViewType = [self viewType:gesture.currentView];
    BOOL isEditing = ( self.editState > BbObjectViewEditState_Default );
    id <BbObjectView> objectView = (id<BbObjectView>)gesture.currentView;
    switch ( self.currentViewType ) {
            
        case BbPatchViewType_Inlet:
        {
            if ( !isEditing && nil != self.selectedInlet && nil != self.selectedOutlet ) {
                //make connection
                [self.delegate objectView:self didConnectPortView:self.selectedOutlet toPortView:self.selectedInlet];
            }
        }
            break;
        case BbPatchViewType_Patch:
        {
            if ( !isEditing && gesture.repeatCount && gesture.movement < kMaxMovement ) {
                // add box
                id <BbObjectView> placeholder = [BbBoxView<BbObjectView> createPlaceholder];
                [self addChildObjectView:objectView];
                [placeholder moveToPoint:gesture.position];
                [self.delegate objectView:self didAddChildObjectView:placeholder];
            }
        }
            break;
        case BbPatchViewType_Object:
        {
            if ( !isEditing ) {
                
                if ( gesture.repeatCount && gesture.movement < kMaxMovement ) {
                    //show box options
                    BOOL canOpen = [self.dataSource objectView:self canOpenChildView:objectView];
                    BOOL canGetHelp = [self.dataSource objectView:self canOpenHelpObjectForChildView:objectView];
                    BOOL canTest = [self.dataSource objectView:self canTestObjectForChildView:objectView];
                    
                }else if ( gesture.duration > kLongPressMinDuration  && gesture.movement < kMaxMovement ){
                    //edit box
                    objectView.editing = [self.delegate objectViewShouldBeginEditing:objectView];
                }
            }
        }
            break;
        case BbPatchViewType_ActionObject:
        {
            if ( !isEditing ) {
                [objectView.delegate sendActionsForObjectView:objectView];
            }
        }
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
        self.hasSelectedInlet = NO;
    }else{
        _selectedInlet.selected = YES;
        self.hasSelectedInlet = YES;
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

#pragma mark - BbGestureHandlerHost

#pragma mark - Helpers

- (BbPatchViewType)viewType:(id)view
{
    if ( nil == self.viewTypes ) {
        self.viewTypes = [BbPatchView myViewTypes];
    }
    
    BbPatchViewType type = ( [self.viewTypes containsObject:[view class]] ) ? (BbPatchViewType)[ self.viewTypes indexOfObject:[view class] ] : BbPatchViewType_Unknown;
    
    if ( type != BbPatchViewType_Unknown ) {
        return type;
    }else{
        id superview = [(UIView *)view superview];
        BbPatchViewType superviewType = ( [self.viewTypes containsObject:[superview class]] ) ? (BbPatchViewType)[ self.viewTypes indexOfObject:[superview class] ] : BbPatchViewType_Unknown;
        if ( superviewType == BbPatchViewType_Object ) {
            return BbPatchViewType_ObjectSubview;
        }
    }
    
    return type;
}

#pragma mark - Connections

- (void)addConnection:(id<BbConnection>)connection
{
    if ( [self.connections containsObject:connection] ) {
        return;
    }
    [self.connections addObject:connection];
    [self setNeedsDisplay];
}

- (void)removeConnection:(id<BbConnection>)connection
{
    if ( ![self.connections containsObject:connection] ) {
        return;
    }
    
    [self.connections removeObject:connection];
    [self setNeedsDisplay];
}

- (CGPoint)connectionOrigin
{
    if ( nil == self.selectedOutlet ) {
        return CGPointZero;
    }
    CGPoint origin = [self convertPoint:self.selectedOutlet.center fromView:self.selectedOutlet.superview];
    return origin;
}

+ (NSArray *)myViewTypes
{
    return @[[BbPatchView class],
             [BbBoxView class],
             [BbInletView class],
             [BbOutletView class]
             ];
}

- (void)redrawConnectionsIfNeeded
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
                [path setLineWidth:6];
                [[UIColor blackColor] setStroke];
                [path stroke];
            }
        }
        
       // [self.connectionPathsToRedraw removeAllObjects];
    }
}


@end
