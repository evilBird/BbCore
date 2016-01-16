//
//  BbPatchViewContainer.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BbPatchView;
@class BbScrollView;

@interface BbPatchViewContainer : UIView 

@property (nonatomic,strong)      BbPatchView       *patchView;
@property (nonatomic,strong)      BbScrollView      *scrollView;

- (void)setPatchView:(BbPatchView *)patchView completion:(void(^)(void))completion;

@end
