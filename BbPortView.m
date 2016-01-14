//
//  BbPortView.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPortView.h"

@interface BbPortView ()

@property (nonatomic,strong)        UIColor             *myFillColor;
@property (nonatomic,strong)        UIColor             *myBorderColor;
@property (nonatomic)               CGAffineTransform   myTransform;

@end

@implementation BbPortView

+ (CGSize)defaultPortViewSize
{
    return CGSizeMake(30, 20);
}

- (instancetype)init
{
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = [BbPortView defaultPortViewSize];
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.defaultFillColor = [UIColor whiteColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.defaultBorderColor = [UIColor blackColor];
    self.selectedBorderColor = [UIColor blackColor];
    self.selectedTransform = CGAffineTransformMakeScale(1.33, 1.33);
    [self updateAppearanceAnimated:NO];
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

- (void)updateAppearanceAnimated:(BOOL)animated
{
    if ( self.selected ) {
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        self.myTransform = self.selectedTransform;
    }else{
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
        self.myTransform = CGAffineTransformIdentity;
    }
    
    if ( !animated ) {
        self.backgroundColor = self.myFillColor;
        self.layer.borderColor = self.myBorderColor.CGColor;
        self.layer.borderWidth = 2.0;
        self.transform = self.myTransform;
        return;
    }
    
    __weak BbPortView *weakself = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakself.backgroundColor = weakself.myFillColor;
        weakself.layer.borderColor = weakself.myBorderColor.CGColor;
        weakself.layer.borderWidth = 2.0;
        weakself.transform = weakself.myTransform;
    }];

}

- (CGSize)intrinsicContentSize
{
    return [BbPortView defaultPortViewSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


@implementation BbInletView



@end


@implementation BbOutletView


@end