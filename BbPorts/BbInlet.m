//
//  BbInlet.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbInlet.h"

@implementation BbInlet

- (void)commonInit
{
    [super commonInit];
    self.scope = BbPortScope_Input;
}

@end
