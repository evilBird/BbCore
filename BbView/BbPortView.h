//
//  BbPortView.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbCoreProtocols.h"
#import "UIView+BbPatch.h"
#import "UIView+Layout.h"

static CGFloat kDefaultPortViewSpacing = 10;

@interface BbPortView : UIView  <BbEntityView>

@property (nonatomic,getter=isSelected)     BOOL                selected;

@property (nonatomic,weak)                  id<BbEntity>        entity;
@property (nonatomic)                       BbEntityViewType    entityViewType;

+ (CGSize)defaultPortViewSize;

@end

@interface BbInletView : BbPortView

@end

@interface BbOutletView : BbPortView

@end