//
//  BbPortView.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbObjectView.h"
#import "UIView+BbPatch.h"
#import "UIView+Layout.h"

static CGFloat kDefaultPortViewSpacing = 10;

@interface BbPortView : UIView  <BbObjectView>

@property (nonatomic,strong)                UIColor             *defaultFillColor;
@property (nonatomic,strong)                UIColor             *selectedFillColor;
@property (nonatomic,strong)                UIColor             *defaultBorderColor;
@property (nonatomic,strong)                UIColor             *selectedBorderColor;
@property (nonatomic)                       CGAffineTransform   selectedTransform;
@property (nonatomic,strong)                NSValue             *objectViewPosition;

@property (nonatomic,getter=isSelected)     BOOL                selected;

@property (nonatomic,weak)                  id<BbObjectViewDataSource>      dataSource;

+ (CGSize)defaultPortViewSize;


@end

@interface BbInletView : BbPortView

- (BbViewType)viewTypeCode;

@end

@interface BbOutletView : BbPortView

- (BbViewType)viewTypeCode;

@end