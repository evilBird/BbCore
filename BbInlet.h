//
//  BbInlet.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPort.h"

@class BbOutlet;

@interface BbInlet : BbPort

@property   (nonatomic,getter=isHotInlet)   BOOL                              hotInlet;
@property   (nonatomic,weak)                BbOutlet                          *targetOutlet;

@end
