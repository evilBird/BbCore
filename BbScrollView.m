//
//  BbScrollView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbScrollView.h"

@implementation BbScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.touchesShouldBegin = YES;
    self.touchesShouldCancel = NO;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return self.touchesShouldCancel;
}

- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return self.touchesShouldBegin;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
