//
//  BbMessageView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbMessageView.h"

@interface BbMessageView ()

@property (nonatomic)    BOOL            highlightLocked;

@end

@implementation BbMessageView

- (void)setHighlightView:(BOOL)highlight
{
    if ( self.highlightLocked ) {
        return;
    }
    
    self.highlightLocked = YES;
    self.highlighted = YES;
    [self updateAppearance];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self unhighlight];
    });
}

- (void)unhighlight
{
    self.highlighted = NO;
    [self updateAppearance];
    self.highlightLocked = NO;
}

- (BbViewType)viewTypeCode
{
    return BbViewType_Control;
}

- (void)setupAppearance
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.defaultFillColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.defaultBorderColor = [UIColor darkGrayColor];
    self.defaultTextColor = [UIColor blackColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.selectedBorderColor = self.defaultBorderColor;
    self.selectedTextColor = self.defaultTextColor;
    self.highlightedFillColor = [UIColor colorWithWhite:0.5 alpha:1];
    self.highlightedTextColor = self.defaultTextColor;
    self.highlightedBorderColor = self.defaultBorderColor;
}

- (void)updateAppearance {
    
    if ( self.isHighlighted ) {
        
        self.myFillColor = self.highlightedFillColor;
        self.myTextColor = self.highlightedTextColor;
        self.myBorderColor = self.highlightedBorderColor;
        
    }else if ( self.isSelected ) {
        
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
    [self setNeedsDisplay];
}

- (void)handleEditingDidChange:(BOOL)editing
{
    if ( editing ) {
        self.myLabel.alpha = 0.0;
        [self setupTextField];
    }else{
        [self tearDownTextField];
        self.myLabel.alpha = 1.0;
        [self.delegate objectView:self userEnteredText:self.myTitleText];
    }
}

- (BOOL)canEdit
{
    return YES;
}

- (BOOL)canReload
{
    return NO;
}

@end
