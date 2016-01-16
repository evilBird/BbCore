//
//  BbAbstractView.h
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import <UIKit/UIKit.h>
#import "BbPortView.h"
#import "BbObjectView.h"
#import "UIView+Layout.h"
#import "UIView+BbPatch.h"

@interface BbAbstractView : UIView <BbObjectView,UITextFieldDelegate>

@property (nonatomic,strong)                    UIColor                         *defaultFillColor;
@property (nonatomic,strong)                    UIColor                         *selectedFillColor;
@property (nonatomic,strong)                    UIColor                         *defaultBorderColor;
@property (nonatomic,strong)                    UIColor                         *selectedBorderColor;
@property (nonatomic,strong)                    UIColor                         *defaultTextColor;
@property (nonatomic,strong)                    UIColor                         *selectedTextColor;
@property (nonatomic,strong)                    NSArray                         *inletViews;
@property (nonatomic,strong)                    NSArray                         *outletViews;

@property (nonatomic,weak)                      id<BbObjectViewDataSource>      dataSource;
@property (nonatomic,weak)                      id<BbObjectViewDelegate>        delegate;
@property (nonatomic,weak)                      id<BbObjectViewEditingDelegate> editingDelegate;
@property (nonatomic,getter=isEditing)          BOOL                            editing;
@property (nonatomic,getter=isSelected)         BOOL                            selected;


@property (nonatomic,weak)                      UIView                          *primaryContentView;

@property (nonatomic,strong)                    NSValue                         *objectViewPosition;
@property (nonatomic)                           NSUInteger                      numIn;
@property (nonatomic)                           NSUInteger                      numOut;
@property (nonatomic,strong)                    NSArray                         *textFieldConstraints;

@property (nonatomic)                           CGPoint                         myPosition;
@property (nonatomic)                           CGPoint                         myOffset;
@property (nonatomic)                           CGSize                          myContentSize;
@property (nonatomic)                           CGFloat                         myMinimumSpacing;
@property (nonatomic,strong)                    NSString                        *myTitleText;
@property (nonatomic,strong)                    UIColor                         *myFillColor;
@property (nonatomic,strong)                    UIColor                         *myBorderColor;
@property (nonatomic,strong)                    UIColor                         *myTextColor;
@property (nonatomic,strong)                    UILabel                         *myLabel;
@property (nonatomic,strong)                    UITextField                     *myTextField;
@property (nonatomic,strong)                    UIStackView                     *inletsStackView;
@property (nonatomic,strong)                    UIStackView                     *outletsStackView;
@property (nonatomic,strong)                    NSLayoutConstraint              *centerXConstraint;
@property (nonatomic,strong)                    NSLayoutConstraint              *centerYConstraint;
@property (nonatomic,strong)                    NSLayoutConstraint              *inletStackRightEdge;
@property (nonatomic,strong)                    NSLayoutConstraint              *outletStackRightEdge;


- (instancetype)initWithTitleText:(NSString *)text inlets:(NSUInteger)numInlets outlets:(NSUInteger)numOutlets;

- (void)setupPrimaryContentView;

- (void)setupInletViews;

- (void)setupOutletViews;

- (void)commonInit;

- (void)setupLabel;

- (void)setupTextField;

- (void)tearDownTextField;

- (NSDictionary *)myTextAttributes;

+ (CGSize)sizeForText:(NSString *)text attributes:(NSDictionary *)attributes;

+ (CGSize)sizeForPortViews:(NSArray *)portViews minimumSpacing:(CGFloat)minimumSpacing;

- (void)calculateSpacingAndContentSize;

- (void)moveToPoint:(CGPoint)point;

- (void)setPosition:(CGPoint)position;

- (CGPoint)getPosition;

- (NSArray *)positionConstraints;

- (void)reloadViewsWithDataSource:(id<BbObjectViewDataSource>)dataSource;

- (void)updateAppearance;

- (void)updateLayout;

- (BOOL)canEdit;

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource;

- (void)setTitleText:(NSString *)titleText;

- (void)setPositionWithValue:(NSValue *)value;

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index;

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index;

- (void)setDataSource:(id<BbObjectViewDataSource>)dataSource reloadViews:(BOOL)reload;

- (void)doAction:(void(^)(void))action;

@end
