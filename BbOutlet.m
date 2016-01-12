//
//  BbOutlet.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbOutlet.h"

@implementation BbOutlet

- (void)commonInit
{
    [super commonInit];
    self.scope = BbPortScope_Output;
}

@end
