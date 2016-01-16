//
//  BbPatchViewController.h
//  BbBridge
//
//  Created by Travis Henspeter on 1/12/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BbPatchViewController : UIViewController

- (void)setPatch:(NSString *)patchTitle withText:(NSString *)patchText completion:(void(^)(void))completion;

@property (nonatomic,strong)        NSString            *patchTitle;
@property (nonatomic,readonly)      NSString            *patchText;

@end
