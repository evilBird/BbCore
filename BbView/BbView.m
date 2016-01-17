//
//  BbBoxView.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbView.h"
#import "UIView+Layout.h"
#import "UIView+BbPatch.h"
#import "BbPortView.h"

@interface BbView ()


@end

@implementation BbView

- (BbViewType)viewTypeCode
{
    return BbViewType_Object;
}

- (void)handleEditingDidChange:(BOOL)editing
{
    if ( editing ) {
        self.myLabel.alpha = 0.0;
        [self setupTextField];
    }else{
        [self tearDownTextField];
        self.myLabel.alpha = 1.0;
        [self.editingDelegate objectView:self didEndEditingWithText:self.myTitleText];
    }
}

- (void)setTitleText:(NSString *)titleText
{
    self.myTitleText = titleText;
    [self updateAppearance];
}

- (void)updateAppearance
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
    
    self.inletsStackView.spacing = self.myMinimumSpacing;
    self.outletsStackView.spacing = self.myMinimumSpacing;
    self.backgroundColor = self.myFillColor;
    self.layer.borderColor = self.myBorderColor.CGColor;
    self.layer.borderWidth = 1.0;
    self.myLabel.textColor = self.myTextColor;
    self.myLabel.text = self.myTitleText;
    self.myTextField.text = self.myTitleText;
    [self.myLabel sizeToFit];
    [self calculateSpacingAndContentSize];
    [self layoutIfNeeded];
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

- (BOOL)canEdit
{
    return YES;
}

#pragma mark - BbObjectView constructors

+ (id<BbObjectView>)createPlaceholder
{
    BbView *placeholder = [[BbView alloc]initWithTitleText:@"New Object" inlets:0 outlets:0];
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
