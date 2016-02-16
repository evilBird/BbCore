//
//  BbMessageView.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbMessageView.h"

@interface BbMessageView ()

@property (nonatomic)    BOOL            highlightLocked;

@end

@implementation BbMessageView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity
{
    BbMessageView *view = [[BbMessageView alloc]initWithEntity:entity];
    return view;
}

@synthesize highlighted = hightlighted_;

- (void)setHighlighted:(BOOL)highlighted
{
    if ( self.highlightLocked ) {
        return;
    }
    self.highlightLocked = YES;
    hightlighted_ = YES;
    [self updateAppearance];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self unhighlight];
    });
}

- (void)unhighlight
{
    hightlighted_ = NO;
    [self updateAppearance];
    self.highlightLocked = NO;
}

- (void)setupAppearance
{
    self.entityViewType = BbEntityViewType_Control;
    self.layer.borderWidth = 2;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.defaultFillColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.defaultBorderColor = [UIColor darkGrayColor];
    self.defaultTextColor = [UIColor blackColor];
    self.selectedFillColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.selectedBorderColor = self.defaultBorderColor;
    self.selectedTextColor = self.defaultTextColor;
    self.highlightedFillColor = [UIColor colorWithWhite:0.5 alpha:1];
    self.highlightedTextColor = self.defaultTextColor;
    self.highlightedBorderColor = self.defaultBorderColor;
}

- (void)setupQuickType {}

@end
