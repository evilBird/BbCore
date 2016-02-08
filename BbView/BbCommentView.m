//
//  BbCommentView.m
//  Pods
//
//  Created by Travis Henspeter on 2/8/16.
//
//

#import "BbCommentView.h"

@implementation BbCommentView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity
{
    return [[BbCommentView alloc]initWithEntity:entity];
}

- (void)setupTextDisplay
{
    UITextField *textField = [UITextField new];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
    [self addSubview:textField];
    [self addConstraint:[textField alignCenterXToSuperOffset:0.0]];
    [self addConstraint:[textField alignCenterYToSuperOffset:0.0]];
    self.textField = textField;
}

- (void)setupAppearance
{
    self.entityViewType = BbEntityViewType_Object;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.defaultFillColor = [UIColor whiteColor];//[UIColor whiteColor];
    self.defaultBorderColor = [UIColor lightGrayColor];
    self.defaultTextColor = [UIColor blackColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.selectedBorderColor = self.defaultBorderColor;
    self.selectedTextColor = self.defaultTextColor;
    
}

- (void)updateContentSize
{
    CGSize oldSize = [self intrinsicContentSize];
    UITextField *textField = self.textField;
    NSString *text = textField.text;
    UIFont *font = textField.font;
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGSize textSize = [text sizeWithAttributes:attributes];
    self.contentWidth = textSize.width;
    self.contentHeight = textSize.height;
    
    CGSize newSize = [self intrinsicContentSize];
    
    if ( !CGSizeEqualToSize(newSize, oldSize)) {
        [self invalidateIntrinsicContentSize];
        [self.superview setNeedsDisplay];
    }
}

@end
