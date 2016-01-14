//
//  BbScrollView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BbScrollView : UIScrollView

@property (nonatomic)       BOOL            touchesShouldBegin;
@property (nonatomic)       BOOL            touchesShouldCancel;

@end
