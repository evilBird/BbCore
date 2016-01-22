//
//  BbPortView.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPortView.h"

@interface BbPortView ()

@property (nonatomic,strong)                UIColor             *defaultFillColor;
@property (nonatomic,strong)                UIColor             *selectedFillColor;
@property (nonatomic,strong)                UIColor             *defaultBorderColor;
@property (nonatomic,strong)                UIColor             *selectedBorderColor;
@property (nonatomic)                       CGAffineTransform   selectedTransform;


@property (nonatomic,strong)                UIColor             *myFillColor;
@property (nonatomic,strong)                UIColor             *myBorderColor;
@property (nonatomic)                       CGAffineTransform   myTransform;

@end

@implementation BbPortView

+ (CGSize)defaultPortViewSize
{
    return CGSizeMake(30, 20);
}

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.defaultFillColor = [UIColor whiteColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.defaultBorderColor = [UIColor blackColor];
    self.selectedBorderColor = [UIColor blackColor];
    self.selectedTransform = CGAffineTransformMakeScale(1.33, 1.33);
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

- (void)didMoveToSuperview
{
    [self invalidateIntrinsicContentSize];
    [self updateAppearance];
}

- (void)updateAppearance
{
    if ( self.isSelected ) {
        
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        self.myTransform = self.selectedTransform;
        
    }else{
        
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
        self.myTransform = CGAffineTransformIdentity;
    }
    
        self.backgroundColor = self.myFillColor;
        self.layer.borderColor = self.myBorderColor.CGColor;
        self.layer.borderWidth = 2.0;
        self.transform = self.myTransform;
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

- (void)commonInit
{
    [super commonInit];
    self.entityViewType = BbEntityViewType_Inlet;
}

@end


@implementation BbOutletView

- (void)commonInit
{
    [super commonInit];
    self.entityViewType = BbEntityViewType_Outlet;
}

@end