//
//  BbBoxView.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbBoxView.h"
#import "UIView+Layout.h"
#import "UIView+BbPatch.h"
#import "BbPortView.h"

static CGFloat kDefaultPortViewSpacing = 10;

@interface BbBoxView () <UITextFieldDelegate>

@property (nonatomic)               NSUInteger          numIn;
@property (nonatomic)               NSUInteger          numOut;
@property (nonatomic,strong)        NSArray             *textFieldConstraints;

@property (nonatomic)               CGPoint             myPosition;
@property (nonatomic)               CGPoint             myOffset;
@property (nonatomic)               CGSize              myContentSize;
@property (nonatomic)               CGFloat             myMinimumSpacing;
@property (nonatomic,strong)        NSString            *myTitleText;
@property (nonatomic,strong)        UIColor             *myFillColor;
@property (nonatomic,strong)        UIColor             *myBorderColor;
@property (nonatomic,strong)        UIColor             *myTextColor;
@property (nonatomic,strong)        UILabel             *myLabel;
@property (nonatomic,strong)        UITextField         *myTextField;
@property (nonatomic,strong)        UIStackView         *inletsStackView;
@property (nonatomic,strong)        UIStackView         *outletsStackView;
@property (nonatomic,strong)        NSLayoutConstraint  *centerXConstraint;
@property (nonatomic,strong)        NSLayoutConstraint  *centerYConstraint;
@property (nonatomic,strong)        NSLayoutConstraint  *inletStackRightEdge;
@property (nonatomic,strong)        NSLayoutConstraint  *outletStackRightEdge;

@end

@implementation BbBoxView

- (instancetype)initWithTitleText:(NSString *)text inlets:(NSUInteger)numInlets outlets:(NSUInteger)numOutlets
{
    self = [super init];
    if ( self ) {
        _myTitleText = text;
        _numIn = numInlets;
        _numOut = numOutlets;
        [self commonInit];
    }
    
    return self;
}

- (void)setupAppearance
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.defaultFillColor = [UIColor blackColor];
    self.defaultBorderColor = [UIColor darkGrayColor];
    self.defaultTextColor = [UIColor whiteColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    self.selectedBorderColor = self.defaultBorderColor;
    self.selectedTextColor = self.defaultTextColor;
}

- (void)setupLabel
{
    self.myLabel = [UILabel new];
    self.myLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.myLabel];
    [self addConstraint:[self.myLabel alignCenterXToSuperOffset:0.0]];
    [self addConstraint:[self.myLabel alignCenterYToSuperOffset:0.0]];
}

- (void)setupInletViews
{
    self.inletViews = [self makeInletViews:self.numIn];
    
    if ( self.inletViews ) {
        
        self.inletsStackView = [[UIStackView alloc]initWithArrangedSubviews:self.inletViews];
        self.inletsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        self.inletsStackView.axis = UILayoutConstraintAxisHorizontal;
        self.inletsStackView.distribution = UIStackViewDistributionEqualSpacing;
        self.inletsStackView.spacing = kDefaultPortViewSpacing;
        [self addSubview:self.inletsStackView];
        [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Top ofView:self.myLabel withInset:0]];
        [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
        self.inletStackRightEdge = [self.inletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
        if ( self.inletViews.count > 1 ) {
            [self addConstraint:self.inletStackRightEdge];
        }
        [self addConstraint:[self pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.inletsStackView withInset:0]];
    }
}

- (void)setupOutletViews
{
    self.outletViews = [self makeOutletViews:self.numOut];

    if ( self.outletViews ) {
        self.outletsStackView = [[UIStackView alloc]initWithArrangedSubviews:self.outletViews];
        self.outletsStackView.translatesAutoresizingMaskIntoConstraints = NO;
        self.outletsStackView.axis = UILayoutConstraintAxisHorizontal;
        self.outletsStackView.distribution = UIStackViewDistributionEqualSpacing;
        self.outletsStackView.spacing = kDefaultPortViewSpacing;
        [self addSubview:self.outletsStackView];
        [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Bottom ofView:self.myLabel withInset:0]];
        [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
        self.outletStackRightEdge = [self.outletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
        if ( self.outletViews.count > 1 ) {
            [self addConstraint:self.outletStackRightEdge];
        }
        [self addConstraint:[self pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.outletsStackView withInset:0]];
    }
}

- (void)commonInit
{
    [self setupAppearance];
    [self setupLabel];
    [self setupInletViews];
    [self setupOutletViews];
    [self updateAppearanceAnimated:NO];
}


- (void)didMoveToSuperview
{
    self.centerXConstraint = [self alignCenterXToSuperOffset:0];
    self.centerYConstraint = [self alignCenterYToSuperOffset:0];
}

- (void)updateLayout
{
    if ( nil == self.superview || CGRectIsEmpty(self.superview.bounds) ) {
        return;
    }
    NSValue *pos = [self.dataSource positionForObjectView:self];
    _myPosition = [pos CGPointValue];
    _myOffset = [self position2Offset:_myPosition];
    [self updatePositionConstraints];
}

- (void)updatePositionConstraints
{
    self.centerXConstraint.constant = _myOffset.x;
    self.centerYConstraint.constant = _myOffset.y;
    [self.superview layoutIfNeeded];
}

- (void)moveToPoint:(CGPoint)point
{
    _myPosition = [self point2Position:point];
    _myOffset = [self position2Offset:point];
    [self updatePositionConstraints];
    [self.delegate objectView:self didChangePosition:[NSValue valueWithCGPoint:_myPosition]];
}

- (void)setPosition:(CGPoint)position
{
    _myPosition = [self point2Position:position];
    _myOffset = [self point2Offset:position];
    [self updatePositionConstraints];
    [self.delegate objectView:self didChangePosition:[NSValue valueWithCGPoint:_myPosition]];
}

- (CGPoint)getPosition
{
    return self.myPosition;
}

- (NSArray *)positionConstraints
{
    return @[self.centerXConstraint,self.centerYConstraint];
}

- (void)setTitle:(NSString *)title
{
    NSString *oldTitle = _myTitleText;
    _myTitleText = title;
    if ( ![title isEqualToString:oldTitle] ) {
        [self updateAppearanceAnimated:YES];
    }
}

- (void)setSelected:(BOOL)selected
{
    BOOL wasSelected = selected;
    _selected = selected;
    BOOL animate = NO;
    if ( _selected != wasSelected ) {
        animate = YES;
    }
    
    [self updateAppearanceAnimated:animate];
}

- (void)setEditing:(BOOL)editing
{
    BOOL wasEditing = _editing;
    _editing = editing;
    
    if ( _editing != wasEditing ) {
        [self handleEditingDidChange:editing];
    }
}

- (void)setupTextField
{
    self.myTextField = [UITextField new];
    self.myTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.myTextField.font = self.myLabel.font;
    self.myTextField.textColor = self.myLabel.textColor;
    self.myTextField.textAlignment = self.myLabel.textAlignment;
    [self insertSubview:self.myTextField aboveSubview:self.myLabel];
    
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObject:[self.myTextField pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.myLabel withInset:0]];
    [temp addObject:[self.myTextField pinEdge:LayoutEdge_Right toEdge:LayoutEdge_Right ofView:self.myLabel withInset:0]];
    [temp addObject:[self.myTextField pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.myLabel withInset:0]];
    [temp addObject:[self.myTextField pinEdge:LayoutEdge_Left toEdge:LayoutEdge_Left ofView:self.myLabel withInset:0]];
    self.textFieldConstraints = temp;
    [self addConstraints:self.textFieldConstraints];
    self.myTextField.delegate = self;
    [self.myTextField becomeFirstResponder];
}

- (void)tearDownTextField
{
    [self removeConstraints:self.textFieldConstraints];
    [self.myTextField removeFromSuperview];
    self.myTextField = nil;
    self.textFieldConstraints = nil;
}

- (void)handleEditingDidChange:(BOOL)editing
{
    if ( editing ) {
        self.myLabel.alpha = 0.0;
        [self setupTextField];
    }else{
        [self tearDownTextField];
        self.myLabel.alpha = 1.0;
    }
}

- (void)reloadViewsWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self removeConstraints:self.constraints];
    [self.inletsStackView removeFromSuperview];
    self.inletViews = nil;
    [self.outletsStackView removeFromSuperview];
    self.outletViews = nil;
    [self.myLabel removeFromSuperview];
    self.myLabel = nil;
    self.numIn = [dataSource numberOfInletsForObjectView:self];
    self.numOut = [dataSource numberOfOutletsForObjectView:self];
    self.myTitleText = [dataSource titleTextForObjectView:self];
    [self setupLabel];
    [self setupInletViews];
    [self setupOutletViews];
    [self updateAppearanceAnimated:NO];
}

- (void)updateAppearanceAnimated:(BOOL)animated
{
    if ( self.selected ) {
        
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        self.myTextColor = self.selectedTextColor;
        
    }else{
        
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
        self.myTextColor = self.defaultTextColor;
    }
    
    [self calculateSpacingAndContentSize];
    
    self.inletsStackView.spacing = self.myMinimumSpacing;
    self.outletsStackView.spacing = self.myMinimumSpacing;
    
    if ( !animated ) {
        self.backgroundColor = self.myFillColor;
        self.layer.borderColor = self.myBorderColor.CGColor;
        self.layer.borderWidth = 1.0;
        self.myLabel.textColor = self.myTextColor;
        self.myLabel.text = self.myTitleText;
        [self.myLabel sizeToFit];
        [self layoutIfNeeded];
        return;
    }
    
    __weak BbBoxView *weakself = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakself.backgroundColor = weakself.myFillColor;
        weakself.layer.borderColor = weakself.myBorderColor.CGColor;
        weakself.layer.borderWidth = 1.0;
        weakself.myLabel.textColor = weakself.myTextColor;
        weakself.myLabel.text = weakself.myTitleText;
        [weakself.myLabel sizeToFit];
        [weakself layoutIfNeeded];
    }];
    
}

- (void)calculateSpacingAndContentSize
{
    CGSize labelSize = [BbBoxView sizeForText:self.myTitleText attributes:[self myTextAttributes]];
    CGSize inletStackSize = [BbBoxView sizeForPortViews:self.inletViews minimumSpacing:kDefaultPortViewSpacing];
    CGSize outletStackSize = [BbBoxView sizeForPortViews:self.outletViews minimumSpacing:kDefaultPortViewSpacing];
    
    CGSize size;
    size.height = labelSize.height+inletStackSize.height+outletStackSize.height;
    CGFloat maxStackWidth = ( inletStackSize.width >= outletStackSize.width ) ? ( inletStackSize.width ) : ( outletStackSize.width );
    CGFloat maxLabelWidth = labelSize.width + [BbPortView defaultPortViewSize].width * 2;
    size.width = ( maxStackWidth >= maxLabelWidth ) ? ( maxStackWidth ) : ( maxLabelWidth );
    self.myContentSize = size;
    
    if ( maxStackWidth >= maxLabelWidth ) {
        self.myMinimumSpacing = kDefaultPortViewSpacing;
    }else{
        
        NSUInteger maxPortCt = ( self.inletViews.count >= self.outletViews.count ) ? ( self.inletViews.count ) : ( self.outletViews.count );
        if ( maxPortCt <= 1 ) {
            self.myMinimumSpacing = kDefaultPortViewSpacing;
        }else{
            CGFloat ct = (CGFloat)maxPortCt;
            CGFloat width = [BbPortView defaultPortViewSize].width;
            self.myMinimumSpacing = round((maxLabelWidth - ( ct * width ))/( ct - 1.0 ));
        }
    }
}

- (NSArray *)makeInletViews:(NSUInteger)numIn
{
    if ( !numIn ) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:numIn];
    for (NSUInteger i = 0; i < numIn ; i ++ ) {
        BbInletView *inletView = [BbInletView new];
        inletView.tag = i;
        [array addObject:inletView];
        [self.delegate objectView:self didAddPortView:inletView inScope:1 atIndex:i];
    }
    
    return array;
}

- (NSArray *)makeOutletViews:(NSUInteger)numOut
{
    if ( !numOut ) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:numOut];
    for (NSUInteger i = 0; i < numOut ; i ++ ) {
        BbOutletView *outletView = [BbOutletView new];
        outletView.tag = i;
        [array addObject:outletView];
        [self.delegate objectView:self didAddPortView:outletView inScope:0 atIndex:i];
    }
    
    return array;
}

- (CGSize)intrinsicContentSize
{
    return self.myContentSize;
}

- (NSDictionary *)myTextAttributes
{
    if ( self.isEditing ) {
        return [self myTextFieldAttributes];
    }else{
        return [self myLabelAttributes];
    }
}

- (NSDictionary *)myTextFieldAttributes
{
    return @{NSFontAttributeName:self.myTextField.font};
}

- (NSDictionary *)myLabelAttributes
{
    return @{NSFontAttributeName:self.myLabel.font};
}

+ (CGSize)sizeForText:(NSString *)text attributes:(NSDictionary *)attributes
{
    return [text sizeWithAttributes:attributes];
}

+ (CGSize)sizeForPortViews:(NSArray *)portViews minimumSpacing:(CGFloat)minimumSpacing
{
    if ( nil == portViews ) {
        return CGSizeMake(0.0, [BbPortView defaultPortViewSize].height);
    }
    CGSize size = [BbPortView defaultPortViewSize];
    size.width *= (CGFloat)portViews.count;
    size.width += (CGFloat)(portViews.count - 1) * minimumSpacing;
    return size;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.isEditing;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [self.editingDelegate objectView:self shouldEndEditingWithText:textField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
}

- (void)textFieldTextDidChange:(id)sender
{
    UITextField *textField = sender;
    [self.editingDelegate objectView:self didEditText:textField.text];
    self.myTitleText = textField.text;
    [self updateAppearanceAnimated:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
}

#pragma mark - BbObjectView constructors

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    _dataSource = dataSource;
    self = [self initWithTitleText:[_dataSource titleTextForObjectView:self] inlets:[_dataSource numberOfInletsForObjectView:self] outlets:[_dataSource numberOfOutletsForObjectView:self]];
    return self;
}

+ (id<BbObjectView>)createPlaceholder
{
    BbBoxView *placeholder = [[BbBoxView alloc]initWithTitleText:@"New Object" inlets:0 outlets:0];
    return placeholder;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
