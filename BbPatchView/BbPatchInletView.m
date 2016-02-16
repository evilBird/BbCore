//
//  BbPatchInletView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchInletView.h"

@implementation BbPatchInletView

- (void)setupTextDisplay
{
    [super setupTextDisplay];
    [(UITextField *)self.textField setPlaceholder:nil];
}

- (BOOL)canEdit
{
    return NO;
}

- (void)setupQuickType {}


@end
