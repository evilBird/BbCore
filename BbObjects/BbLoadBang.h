//
//  BbLoadBang.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbObject+Compatibility.h"
static NSString *kLoadBangNotification = @"com.bb.LoadBang";

@interface BbLoadBang : BbObject

- (void)parentPatchFinishedLoading;

@end
