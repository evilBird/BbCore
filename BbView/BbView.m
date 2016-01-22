//
//  BbBoxView.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbView.h"

@interface BbView ()


@end

@implementation BbView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity
{
    BbView *view = [[BbView alloc]initWithEntity:entity];
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
