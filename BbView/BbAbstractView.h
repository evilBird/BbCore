//
//  BbAbstractView.h
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import <UIKit/UIKit.h>
#import "BbPortView.h"
#import "BbCoreProtocols.h"
#import "UIView+Layout.h"
#import "UIView+BbPatch.h"

@interface BbAbstractView : UIView <BbEntityView,BbObjectView,UITextFieldDelegate>

@property (nonatomic,weak)                      id<BbEntity,BbObject>           entity;
@property (nonatomic,weak)                      id<BbObjectViewEditingDelegate> editingDelegate;

@property (nonatomic,strong)                    NSHashTable                     *inletViews;
@property (nonatomic,strong)                    NSHashTable                     *outletViews;

@property (nonatomic,strong)                    NSValue                         *position;
@property (nonatomic,strong)                    NSString                        *titleText;

@property (nonatomic,strong)                    id                              textField;

@property (nonatomic,getter=isEditing)          BOOL                            editing;
@property (nonatomic,getter=isSelected)         BOOL                            selected;
@property (nonatomic,getter=isHighlighted)      BOOL                            highlighted;
@property (nonatomic,getter=isPlaceholder)      BOOL                            placeholder;

@property (nonatomic)                           BbEntityViewType                entityViewType;

- (instancetype)initWithEntity:(id<BbEntity,BbObject>)entity;

- (void)addChildEntityView:(id<BbEntityView>)entityView;

- (void)removeChildEntityView:(id<BbEntityView>)entityView;

- (void)moveToPoint:(NSValue *)pointValue;

- (void)moveToPosition:(NSValue *)positionValue;

- (void)updateAppearance;

- (NSArray *)positionConstraints;

- (BOOL)canEdit;

- (void)commonInit;

@property (nonatomic,strong)                    UIColor                         *defaultFillColor;
@property (nonatomic,strong)                    UIColor                         *selectedFillColor;
@property (nonatomic,strong)                    UIColor                         *defaultBorderColor;
@property (nonatomic,strong)                    UIColor                         *selectedBorderColor;
@property (nonatomic,strong)                    UIColor                         *defaultTextColor;
@property (nonatomic,strong)                    UIColor                         *selectedTextColor;
@property (nonatomic,strong)                    UIColor                         *highlightedFillColor;
@property (nonatomic,strong)                    UIColor                         *highlightedBorderColor;
@property (nonatomic,strong)                    UIColor                         *highlightedTextColor;

@property (nonatomic)                           NSUInteger                      contentWidth;
@property (nonatomic)                           NSUInteger                      contentHeight;

@property (nonatomic,strong)                    UIColor                         *myFillColor;
@property (nonatomic,strong)                    UIColor                         *myBorderColor;
@property (nonatomic,strong)                    UIColor                         *myTextColor;

@property (nonatomic,strong)                    UIStackView                     *inletsStackView;
@property (nonatomic,strong)                    UIStackView                     *outletsStackView;

@property (nonatomic,strong)                    NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)                    NSLayoutConstraint              *centerYConstraint;

@property (nonatomic,strong)                    NSLayoutConstraint              *inletStackRightEdge;
@property (nonatomic,strong)                    NSLayoutConstraint              *outletStackRightEdge;



@end
