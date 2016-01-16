//
//  BSDPrint.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BbObject.h"

static NSString *kPrintNotificationChannel = @"com.birdsound.bb.bsdprint";

@interface BbPrint : BbObject

@property (nonatomic,strong)NSString *text;

@end
