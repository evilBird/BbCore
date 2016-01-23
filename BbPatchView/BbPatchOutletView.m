//
//  BbPatchOutletView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchOutletView.h"

@implementation BbPatchOutletView

- (void)setupTextDisplay
{
    [super setupTextDisplay];
    [(UITextField *)self.textField setPlaceholder:nil];
}

- (BOOL)canEdit
{
    return NO;
}

@end
