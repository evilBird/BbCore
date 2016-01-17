//
//  BbAbstractView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbAbstractView.h"

@implementation BbAbstractView

- (BbViewType)viewTypeCode
{
    return BbViewType_Object;
}

- (BOOL)canReload
{
    return YES;
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
    _myOffset = [self point2Offset:point];
    [self updatePositionConstraints];
    _objectViewPosition = [NSValue valueWithCGPoint:_myPosition];
    [self.delegate objectView:self didChangePosition:_objectViewPosition];
}

- (void)setPositionWithValue:(NSValue *)value
{
    _objectViewPosition = value;
    CGPoint point = [self position2Point:[value CGPointValue]];
    [self moveToPoint:point];
}

- (void)setPosition:(CGPoint)position
{
    _myPosition = [self point2Position:position];
    _myOffset = [self point2Offset:position];
    [self updatePositionConstraints];
    _objectViewPosition = [NSValue valueWithCGPoint:_myPosition];
    [self.delegate objectView:self didChangePosition:_objectViewPosition];
}

- (NSArray *)positionConstraints
{
    return @[self.centerXConstraint,self.centerYConstraint];
}

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

- (void)commonInit
{
    [self setupAppearance];
    [self setupPrimaryContentView];
    [self setupInletViews];
    [self setupOutletViews];
    [self updateAppearance];
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

- (void)setupPrimaryContentView {
    
    [self setupLabel];
    self.primaryContentView = self.myLabel;
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
        [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Top ofView:self.primaryContentView withInset:0]];
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
        [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Bottom ofView:self.primaryContentView withInset:0]];
        [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
        self.outletStackRightEdge = [self.outletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
        if ( self.outletViews.count > 1 ) {
            [self addConstraint:self.outletStackRightEdge];
        }
        [self addConstraint:[self pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.outletsStackView withInset:0]];
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

- (void)didMoveToSuperview
{
    self.centerXConstraint = [self alignCenterXToSuperOffset:0];
    self.centerYConstraint = [self alignCenterYToSuperOffset:0];
}


- (BOOL)canEdit
{
    return YES;
}

- (void)setSelected:(BOOL)selected
{
    BOOL wasSelected = selected;
    _selected = selected;
    BOOL animate = NO;
    if ( _selected != wasSelected ) {
        animate = YES;
    }
    
    [self updateAppearance];
}

- (void)setEditing:(BOOL)editing
{
    BOOL wasEditing = _editing;
    _editing = editing;
    
    if ( _editing != wasEditing ) {
        [self handleEditingDidChange:editing];
    }
}

- (void)handleEditingDidChange:(BOOL)editing {}

- (void)updateAppearance {

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
    [self setupPrimaryContentView];
    [self setupInletViews];
    [self setupOutletViews];
    [self updateAppearance];
}

- (instancetype)initWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    _dataSource = dataSource;
    self = [self initWithTitleText:[_dataSource titleTextForObjectView:self] inlets:[_dataSource numberOfInletsForObjectView:self] outlets:[_dataSource numberOfOutletsForObjectView:self]];
    return self;
}

- (void)setTitleText:(NSString *)titleText
{
    self.myTitleText = titleText;
    [self updateAppearance];
}

+ (id<BbObjectView>)createViewWithDataSource:(id<BbObjectViewDataSource>)dataSource
{
    return [[[self class] alloc]initWithDataSource:dataSource];
}

- (id<BbObjectView>)viewForInletAtIndex:(NSUInteger)index
{
    if ( nil == self.inletViews || index >= self.inletViews.count ) {
        return nil;
    }
    
    return self.inletViews[index];
}

- (id<BbObjectView>)viewForOutletAtIndex:(NSUInteger)index
{
    if ( nil == self.outletViews || index >= self.outletViews.count ) {
        return nil;
    }
    
    return self.outletViews[index];
}
- (void)setDataSource:(id<BbObjectViewDataSource>)dataSource reloadViews:(BOOL)reload
{
    if ( reload ) {
        [self reloadViewsWithDataSource:dataSource];
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

- (CGSize)intrinsicContentSize
{
    return self.myContentSize;
}

- (NSDictionary *)myTextAttributes
{
    return @{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize]]};
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

- (void)calculateSpacingAndContentSize
{
    CGSize labelSize = [BbAbstractView sizeForText:self.myTitleText attributes:[self myTextAttributes]];
    CGSize inletStackSize = [BbAbstractView sizeForPortViews:self.inletViews minimumSpacing:kDefaultPortViewSpacing];
    CGSize outletStackSize = [BbAbstractView sizeForPortViews:self.outletViews minimumSpacing:kDefaultPortViewSpacing];
    
    CGSize size;
    size.height = labelSize.height+inletStackSize.height+outletStackSize.height;
    CGFloat maxStackWidth = ( inletStackSize.width >= outletStackSize.width ) ? ( inletStackSize.width ) : ( outletStackSize.width );
    CGFloat maxLabelWidth = labelSize.width + [BbPortView defaultPortViewSize].width * 2;
    size.width = ( maxStackWidth >= maxLabelWidth ) ? ( maxStackWidth ) : ( maxLabelWidth );
    
    if ( !CGSizeEqualToSize(size, _myContentSize) ) {
        [self invalidateIntrinsicContentSize];
    }
    
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

#pragma mark - UITextFieldDelegate


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
    [self updateAppearance];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
    self.myTitleText = textField.text;
    self.editing = NO;
    [self updateAppearance];
}

@end
