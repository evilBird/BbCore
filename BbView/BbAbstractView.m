//
//  BbAbstractView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbAbstractView.h"

NSUInteger ReturnGreatest (NSUInteger value1, NSUInteger value2)
{
    if ( value1 >= value2 ) {
        return value1;
    }else{
        return value2;
    }
}



@interface BbAbstractView ()


@end

@implementation BbAbstractView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity
{
    return [[BbAbstractView alloc]initWithEntity:entity];
}

- (instancetype)initWithEntity:(id<BbEntity,BbObject>)entity
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
    _inletViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _outletViews = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    _selected = NO;
    _highlighted = NO;
    _editing = NO;
    _position = nil;
    _entityViewType = BbEntityViewType_Object;
    [self setupAppearance];
    [self setupPortviewStacks];
    [self setupTextDisplay];
    if ( nil == self.entity ) {
        self.placeholder = YES;
    }
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

- (void)setupPortviewStacks
{
    self.inletsStackView = [[UIStackView alloc]init];
    self.inletsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inletsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.inletsStackView.distribution = UIStackViewDistributionEqualSpacing;
    self.inletsStackView.spacing = kDefaultPortViewSpacing;
    [self addSubview:self.inletsStackView];
    [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self addConstraint:[self.inletsStackView pinEdge:LayoutEdge_Top toSuperviewEdge:LayoutEdge_Top]];
    
    self.inletStackRightEdge = [self.inletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
    
    self.outletsStackView = [[UIStackView alloc]init];
    self.outletsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.outletsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.outletsStackView.distribution = UIStackViewDistributionEqualSpacing;
    self.outletsStackView.spacing = kDefaultPortViewSpacing;
    [self addSubview:self.outletsStackView];
    
    [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Left toSuperviewEdge:LayoutEdge_Left]];
    [self addConstraint:[self.outletsStackView pinEdge:LayoutEdge_Bottom toSuperviewEdge:LayoutEdge_Bottom]];
    
    self.outletStackRightEdge = [self.outletsStackView pinEdge:LayoutEdge_Right toSuperviewEdge:LayoutEdge_Right];
}

- (void)setupTextDisplay
{
    UITextField *textField = [UITextField new];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentCenter;
    [self addSubview:textField];
    [self addConstraint:[textField alignCenterXToSuperOffset:0.0]];
    [self addConstraint:[textField alignCenterYToSuperOffset:0.0]];
    self.textField = textField;
}

- (void)setupPositionConstraints
{
    self.centerXConstraint = [self alignCenterXToSuperOffset:0];
    self.centerYConstraint = [self alignCenterYToSuperOffset:0];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setupPositionConstraints];
    if ( nil != self.entity ) {
        NSString *viewArgs = self.entity.viewArguments;
        _position = [BbHelpers positionFromViewArgs:viewArgs];
        [self moveToPosition:_position];
        _titleText = self.entity.displayText;
    }else{
        _titleText = @"Enter Text Here . . . ";
    }
    
    [self updateAppearance];
}

- (void)moveToPoint:(NSValue *)pointValue
{
    if ( nil == self.superview ) {
        return;
    }
    
    CGPoint point = pointValue.CGPointValue;
    CGPoint position = [self point2Position:point];
    [self moveToPosition:[NSValue valueWithCGPoint:position]];
    [self.entity objectView:self didChangeValue:[NSValue valueWithCGPoint:position] forViewArgumentKey:kViewArgumentKeyPosition];
}

- (void)moveToPosition:(NSValue *)positionValue
{
    if ( nil == self.superview || CGRectIsEmpty(self.superview.bounds)) {
        return;
    }
    
    _position = positionValue;
    CGPoint position = [positionValue CGPointValue];
    CGPoint offsets = [self position2Offset:position];
    self.centerXConstraint.constant = offsets.x;
    self.centerYConstraint.constant = offsets.y;
    [self.superview layoutIfNeeded];
}

- (BOOL)canEdit
{
    if ( self.isPlaceholder ) {
        return YES;
    }
    
    return YES;
}

- (NSArray *)positionConstraints
{
    if ( nil == self.centerXConstraint || nil == self.centerYConstraint ) {
        return nil;
    }
    
    return @[self.centerXConstraint,self.centerYConstraint];
}

- (void)setEditing:(BOOL)editing
{
    BOOL wasEditing = _editing;
    _editing = editing;
    if ( _editing != wasEditing ) {
        [self editingStateDidChange:editing];
    }
}

- (void)setSelected:(BOOL)selected
{
    BOOL wasSelected = _selected;
    _selected = selected;
    if ( _selected != wasSelected ) {
        [self updateAppearance];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    BOOL wasHighlighted = _highlighted;
    _highlighted = highlighted;
    if ( _highlighted != wasHighlighted ) {
        [self updateAppearance];
    }
}

- (void)setPlaceholder:(BOOL)placeholder
{
    BOOL wasPlaceholder = _placeholder;
    if ( _placeholder != wasPlaceholder ) {
        [self placeholderStatusDidChange:placeholder];
    }
}


- (void)editingStateDidChange:(BOOL)editing
{
    if (!editing) {
        [self.editingDelegate objectView:self didEndEditingWithUserText:self.titleText];
    }else if ( nil != self.entity ){
        self.editingDelegate = [self.entity editingDelegateForObjectView:self];
        [(UITextField *)self.textField becomeFirstResponder];
    }else{
        [(UITextField *)self.textField setText:@""];
        [(UITextField *)self.textField becomeFirstResponder];
    }
}

- (void)placeholderStatusDidChange:(BOOL)placeholder
{
    if ( !placeholder ) {
        [(UITextField *)self.textField setPlaceholder:@""];
    }else{
        [(UITextField *)self.textField setPlaceholder:@"Enter text here..."];
    }
}

- (void)updateAppearance
{
    if ( self.isHighlighted ) {
        
        self.myFillColor = self.highlightedFillColor;
        self.myBorderColor = self.highlightedBorderColor;
        self.myTextColor = self.highlightedTextColor;
        
    }else if ( self.isSelected ) {
        
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        self.myTextColor = self.selectedTextColor;
        
    }else {
        
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
        self.myTextColor = self.defaultTextColor;
    }
    
    self.backgroundColor = self.myFillColor;
    self.layer.borderColor = self.myBorderColor.CGColor;
    [(UITextField *)self.textField setTextColor:self.myTextColor];
    [(UITextField *)self.textField setText:self.titleText];
    [self setNeedsDisplay];
    [self updateContentSize];
}

- (void)updateContentSize
{
    CGSize oldSize = [self intrinsicContentSize];
    
    CGSize textSize = [self textSize];
    CGSize portViewSize = [BbPortView defaultPortViewSize];
    
    NSUInteger actualTextHeight = (NSUInteger)(round(textSize.height));
    NSUInteger minimumTextHeight = (NSUInteger)(round(portViewSize.height*1));
    NSUInteger textHeight = ReturnGreatest(actualTextHeight, minimumTextHeight);
    self.contentHeight = (textHeight + portViewSize.height + portViewSize.height );
    
    NSUInteger actualTextWidth = (NSUInteger)(round(textSize.width));
    NSUInteger minimumTextWidth = (NSUInteger)(round(portViewSize.width*1));
    NSUInteger textWidth = ReturnGreatest(actualTextWidth, minimumTextWidth) + portViewSize.width + portViewSize.width;
    
    NSUInteger inletsWidth = (NSUInteger)(round(self.inletsStackView.frame.size.width));
    NSUInteger outletsWidth = (NSUInteger)(round(self.outletsStackView.frame.size.width));
    NSUInteger portsWidth = ReturnGreatest(inletsWidth, outletsWidth);
    self.contentWidth = ReturnGreatest(portsWidth, textWidth);
    
    CGSize newSize = [self intrinsicContentSize];
    
    if ( !CGSizeEqualToSize(newSize, oldSize)) {
        [self invalidateIntrinsicContentSize];
        [self.superview setNeedsDisplay];
    }
}

- (CGSize)textSize
{
    UITextField *textField = (UITextField *)self.textField;
    NSString *text = textField.text;
    
    if ( nil == text ) {
        return CGSizeZero;
    }
    
    NSDictionary *textAttributes = nil;
    
    if ( textField.isEditing ) {
        textAttributes = textField.typingAttributes;
    }else{
        textAttributes = textField.defaultTextAttributes;
    }
    
    return [text sizeWithAttributes:textAttributes];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake((CGFloat)_contentWidth, (CGFloat)_contentHeight);
}

- (void)addChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView ) {
        return;
    }
    
    if ( [self.inletViews containsObject:entityView] || [self.outletViews containsObject:entityView] ) {
        return;
    }
    
    if ( [entityView isKindOfClass:[BbInletView class]] ) {
        NSUInteger oldCount = self.inletViews.allObjects.count;
        [self.inletViews addObject:entityView];
        NSUInteger newCount = self.inletViews.allObjects.count;
        NSUInteger index = [entityView.entity indexInParentEntity];
        [self.inletsStackView insertArrangedSubview:(UIView *)entityView atIndex:index];
        if ( newCount >= 2 && oldCount < 2 ) {
            [self addConstraint:self.inletStackRightEdge];
            [self layoutIfNeeded];
        }
        
    }else if ( [entityView isKindOfClass:[BbOutletView class]] ){
        
        
        NSUInteger oldCount = self.outletViews.allObjects.count;
        [self.outletViews addObject:entityView];
        NSUInteger newCount = self.outletViews.allObjects.count;
        NSUInteger index = [entityView.entity indexInParentEntity];
        [self.outletsStackView insertArrangedSubview:(UIView *)entityView atIndex:index];
        if ( newCount >= 2 && oldCount < 2 ) {
            [self addConstraint:self.outletStackRightEdge];
            [self layoutIfNeeded];
        }
    }
    
    [self updateContentSize];
}

- (void)removeChildEntityView:(id<BbEntityView>)entityView
{
    if ( nil == entityView ) {
        return;
    }
    
    if ( [entityView isKindOfClass:[BbInletView class]] ) {
        NSUInteger oldCount = self.inletViews.allObjects.count;
        [self.inletViews removeObject:entityView];
        [self.inletsStackView removeArrangedSubview:(UIView *)entityView];
        NSUInteger newCount = self.inletViews.allObjects.count;
        
        if ( newCount < 2 && oldCount >= 2){
            [self removeConstraint:self.inletStackRightEdge];
            [self layoutIfNeeded];
        }
        
    }else if ( [entityView isKindOfClass:[BbOutletView class]] ){
        
        NSUInteger oldCount = self.outletViews.allObjects.count;
        [self.outletViews removeObject:entityView];
        [self.outletsStackView removeArrangedSubview:(UIView *)entityView];
        NSUInteger newCount = self.outletViews.allObjects.count;
        if ( newCount < 2 && oldCount >= 2 ){
            [self removeConstraint:self.outletStackRightEdge];
            [self layoutIfNeeded];
        }
    }
    
    [self updateContentSize];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.isEditing;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return self.isPlaceholder;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
    [self.entity objectView:self didBeginEditingWithDelegate:self.editingDelegate];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField removeTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventAllEditingEvents];
    self.titleText = textField.text;
    [self updateAppearance];
    self.editing = NO;
}

- (void)textFieldTextDidChange:(id)sender
{
    UITextField *textField = sender;
    self.titleText = textField.text;
    NSString *suggestedCompletion = [self.editingDelegate objectView:self suggestCompletionForUserText:textField.text];
    NSLog(@"suggested completion: %@",suggestedCompletion);
    [self updateAppearance];
}

@end
