//
//  BbBoxView.h
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BbAbstractView.h"

@class BbInletView;
@class BbOutletView;

@interface BbView : BbAbstractView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity;

@end