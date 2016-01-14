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
#import "BbBoxView.h"

@interface BbPatchViewContainer () <BbPatchViewEventDelegate,UIScrollViewDelegate>

@end

@implementation BbPatchViewContainer

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithPatchView:(BbPatchView *)patchView
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if ( self ) {
        _patchView = patchView;
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    [self setupScrollView];
    [self setupPatchView];
    [self finishSetup];
}

- (void)setupScrollView
{
    self.scrollView = [[BbScrollView alloc]initWithFrame:self.bounds];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    [self addSubview:self.scrollView];
}

- (void)createPatchView
{
    CGRect screen = [UIScreen mainScreen].bounds;
    CGSize patchViewSize = screen.size;
    CGFloat edge = ( patchViewSize.width >= patchViewSize.height ) ? ( patchViewSize.width ) : ( patchViewSize.height );
    edge*=2;
    CGRect patchViewRect = CGRectMake(0.0, 0.0, edge, edge);
    self.patchView = [[BbPatchView alloc]initWithFrame:patchViewRect];
}

- (void)setupPatchView
{
    self.patchView.eventDelegate = self;
    self.patchView.backgroundColor = [UIColor whiteColor];
}

- (void)finishSetup
{
    [self.scrollView addSubview:self.patchView];
    CGRect bounds = self.bounds;
    CGSize size = bounds.size;
    CGSize objectSize = [[self.patchView.dataSource sizeForObjectView:self.patchView]CGSizeValue];
    CGSize contentSize;
    
    contentSize.width = objectSize.width*size.width;
    contentSize.height = objectSize.height*size.height;
    CGRect patchViewRect;
    patchViewRect.origin = CGPointZero;
    patchViewRect.size = contentSize;
    self.patchView.frame = patchViewRect;
    self.scrollView.contentSize = contentSize;
    self.scrollView.zoomScale = [(NSNumber *)[self.patchView.dataSource zoomScaleForObjectView:self.patchView]doubleValue];
    CGPoint offset = [[self.patchView.dataSource contentOffsetForObjectView:self.patchView]CGPointValue];
    offset.x*=size.width;
    offset.y*=size.height;
    self.scrollView.contentOffset = offset;
    [self addConstraints:[self.scrollView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
}

- (void)commonInit
{
    [self setupScrollView];
    [self createPatchView];
    [self finishSetup];
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
