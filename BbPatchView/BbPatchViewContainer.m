//
//  BbPatchViewContainer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbPatchViewContainer.h"
#import "BbScrollView.h"
#import "BbPatchView.h"
#import "UIView+Layout.h"
#import "UIView+BbPatch.h"
#import "BbView.h"

@interface BbPatchViewContainer () <BbPatchViewEventDelegate,UIScrollViewDelegate>

@end

@implementation BbPatchViewContainer

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self setupScrollView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self setupScrollView];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self setupScrollView];
    }
    
    return self;
}

- (void)setupScrollView
{
    self.scrollView = [[BbScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.backgroundColor = [UIColor greenColor];
    [self addSubview:self.scrollView];
    [self addConstraints:[self.scrollView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
}

- (void)setPatchView:(BbPatchView *)patchView completion:(void (^)(void))completion
{
    _patchView = patchView;
    [self setupPatchView];
    if ( nil != completion ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }
}

- (void)setupPatchView
{
    self.patchView.eventDelegate = self;
    self.patchView.backgroundColor = [UIColor yellowColor];
    CGSize sizeFactor = [self.patchView.dataSource sizeForObjectView:self.patchView].CGSizeValue;
    CGRect bounds = self.bounds;
    bounds.size = [self multiplySize:bounds.size withSize:sizeFactor];
    self.patchView.frame = bounds;
    [self.scrollView addSubview:self.patchView];

    //[self addConstraints:[self constrainSizeOfSubview:self.patchView withSizeFactor:sizeFactor]];
    //[self layoutSubviews];
    
    self.scrollView.contentSize = self.patchView.bounds.size;
    self.scrollView.zoomScale = [(NSNumber *)[self.patchView.dataSource zoomScaleForObjectView:self.patchView]doubleValue];
    CGPoint offsetFactor = [self.patchView.dataSource contentOffsetForObjectView:self.patchView].CGPointValue;
    offsetFactor.x *= self.patchView.bounds.size.width;
    offsetFactor.y *= self.patchView.bounds.size.height;
    self.scrollView.contentOffset = offsetFactor;
}

- (NSArray *)constrainSizeOfSubview:(UIView *)subview withSizeFactor:(CGSize)sizeFactor
{
    NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:2];
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:sizeFactor.width
                                                                        constant:0.0];
    [constraints addObject:widthConstraint];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subview
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:sizeFactor.height
                                                                         constant:0.0];
    [constraints addObject:heightConstraint];
    
    return constraints;
}


#pragma mark - BbPatchViewEventDelegate

- (void)patchView:(id)sender setScrollViewShouldBegin:(BOOL)shouldBegin
{
    self.scrollView.touchesShouldBegin = shouldBegin;
}

- (void)patchView:(id)sender setScrollViewShouldCancel:(BOOL)shouldCancel
{
    self.scrollView.touchesShouldCancel = shouldCancel;
}

- (void)patchView:(id)sender didChangeSize:(NSValue *)size
{
    self.scrollView.contentSize = [size CGSizeValue];
    [self setNeedsDisplay];
}

- (void)patchView:(id)sender didChangeContentOffset:(NSValue *)offset
{
    self.scrollView.contentOffset = [offset CGPointValue];
    [self setNeedsDisplay];
}

- (void)patchView:(id)sender didChangeZoomScale:(NSValue *)zoom
{
    self.scrollView.zoomScale = [(NSNumber *)zoom doubleValue];
    [self setNeedsDisplay];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.patchView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self.patchView setNeedsDisplay];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.patchView.delegate objectView:self.patchView didChangeContentOffset:[NSValue valueWithCGPoint:scrollView.contentOffset]];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.patchView.delegate objectView:self.patchView didChangeZoomScale:@(scale)];
    [self.patchView setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
