//
//  BbBangView.m
//  Pods
//
//  Created by Travis Henspeter on 2/3/16.
//
//

#import "BbBangView.h"

@interface BbBangView ()

@property (nonatomic)               BOOL            highlightLocked;
@property (nonatomic,strong)        UIView          *circleView;
@property (nonatomic,strong)        UIColor         *defaultBackgroundFillColor;
@property (nonatomic,strong)        UIColor         *selectedBackgroundFillColor;

@end

@implementation BbBangView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity
{
    BbBangView *view = [[BbBangView alloc]initWithEntity:entity];
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

- (void)commonInit
{
    [super commonInit];
    self.circleView = [UIView new];
    self.circleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self insertSubview:self.circleView atIndex:0];
    [self addConstraints:[self.circleView pinEdgesToSuperWithInsets:UIEdgeInsetsMake(6, 6, -6, -6)]];
    [self updateAppearance];
}

- (void)setupAppearance
{
    self.entityViewType = BbEntityViewType_Control;
    self.layer.borderWidth = 2;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.defaultBackgroundFillColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.selectedBackgroundFillColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    self.defaultBorderColor = [UIColor darkGrayColor];
    self.defaultTextColor = [UIColor blackColor];
    
    self.defaultFillColor = [UIColor colorWithWhite:0.33 alpha:1.0];
    
    self.selectedFillColor = [UIColor colorWithWhite:0.47 alpha:1.0];
    
    self.selectedBorderColor = self.defaultBorderColor;
    self.selectedTextColor = self.defaultTextColor;
    
    self.highlightedFillColor = [UIColor colorWithWhite:0.0833 alpha:1];
    self.highlightedTextColor = self.defaultTextColor;
    self.highlightedBorderColor = self.defaultBorderColor;
    
}

- (void)updateAppearance
{
    UIColor *myBackgroundFillColor = nil;
    
    if ( self.isHighlighted ) {
        myBackgroundFillColor = self.defaultBackgroundFillColor;
        self.myFillColor = self.highlightedFillColor;
        self.myBorderColor = self.highlightedBorderColor;
        self.myTextColor = self.highlightedTextColor;
        
    }else if ( self.isSelected ) {
        myBackgroundFillColor = self.selectedBackgroundFillColor;
        self.myFillColor = self.selectedFillColor;
        self.myBorderColor = self.selectedBorderColor;
        self.myTextColor = self.selectedTextColor;
        
    }else {
        myBackgroundFillColor = self.defaultBackgroundFillColor;
        self.myFillColor = self.defaultFillColor;
        self.myBorderColor = self.defaultBorderColor;
        self.myTextColor = self.defaultTextColor;
    }
    
    self.backgroundColor = myBackgroundFillColor;
    self.layer.borderColor = self.myBorderColor.CGColor;
    self.circleView.backgroundColor = self.myFillColor;
    self.circleView.layer.borderColor = self.myBorderColor.CGColor;
    self.circleView.layer.borderWidth = 2;
    self.circleView.layer.cornerRadius = (CGRectGetWidth(self.circleView.bounds)/2.0);
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
    CGSize portSize = [BbPortView defaultPortViewSize];
    CGFloat length = ReturnGreatest(portSize.width, portSize.height)*3;
    return CGSizeMake(length, length);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
