//
//  BbConnectionPath.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbConnectionPath.h"

@interface BbConnectionPath ()

@property (nonatomic,strong)            UIColor         *defaultColor;
@property (nonatomic,strong)            UIColor         *selectedColor;
@property (nonatomic)                   CGFloat         defaultWidth;
@property (nonatomic)                   CGFloat         selectedWidth;

@end

@implementation BbConnectionPath

+ (BbConnectionPath *)addConnectionPathWithDelegate:(id<BbConnectionPathDelegate>)delegate dataSource:(id<BbConnectionPathDataSource>)dataSource
{
    BbConnectionPath *path = [[BbConnectionPath alloc]initWithDelegate:delegate dataSource:dataSource];
    [path.delegate addConnectionPath:path];
    [path setNeedsRedraw:YES];
    return path;
}

- (instancetype)initWithDelegate:(id<BbConnectionPathDelegate>)delegate dataSource:(id<BbConnectionPathDataSource>)dataSource
{
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _dataSource = dataSource;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _connectionID = [self.dataSource connectionIDForConnectionPath:self];
    self.defaultColor = [UIColor blackColor];
    self.selectedColor = [UIColor darkGrayColor];
    self.defaultWidth = 6;
    self.selectedWidth = 8;
}

#pragma mark - BbConnectionPath Protocol

- (void)setNeedsRedraw:(BOOL)needsRedraw
{
    _needsRedraw = needsRedraw;
    if ( needsRedraw ) {
        [self prepareToRedraw];
        [self.delegate redrawConnectionPath:self];
    }
}

- (void)setIsOrphan:(BOOL)isOrphan
{
    _isOrphan = isOrphan;
    if ( isOrphan ) {
        [self.delegate removeConnectionPath:self];
    }
}

- (void)removeFromParentView
{
    [self.delegate removeConnectionPath:self];
    [_bezierPath removeAllPoints];
}

- (void)setOriginPoint:(NSValue *)originPoint
{
    [self prepareToRedrawWithOrigin:originPoint
                           terminus:[self.dataSource terminalPointForConnectionPath:self]
     ];
    [self.delegate redrawConnectionPath:self];
}

- (void)setTerminalPoint:(NSValue *)terminalPoint
{
    [self prepareToRedrawWithOrigin:[self.dataSource originPointForConnectionPath:self]
                           terminus:terminalPoint];
    [self.delegate redrawConnectionPath:self];
}

- (void)setSelected:(BOOL)selected
{
    BOOL wasSelected = selected;
    _selected = selected;
    if ( _selected != wasSelected ) {
        [self prepareToRedraw];
        [self.delegate redrawConnectionPath:self];
    }
}

#pragma mark - Private

- (void)prepareToRedraw
{
    [self prepareToRedrawWithOrigin:[self.dataSource originPointForConnectionPath:self]
                           terminus:[self.dataSource terminalPointForConnectionPath:self]
     ];
}

- (void)prepareToRedrawWithOrigin:(NSValue *)originPoint terminus:(NSValue *)terminalPoint
{
    CGPoint origin = originPoint.CGPointValue;
    CGPoint terminus = terminalPoint.CGPointValue;
    _bezierPath = [self bezierPathWithOrigin:origin terminus:terminus];
    _bezierPath.lineWidth = ( self.isSelected ) ? ( self.selectedWidth ) : ( self.defaultWidth );
    _preferredColor = ( self.isSelected ) ? ( self.selectedColor ) : ( self.defaultColor );
}

- (UIBezierPath *)bezierPathWithOrigin:(CGPoint)origin terminus:(CGPoint)terminus
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:origin];
    [path addLineToPoint:terminus];
    return path;
}

@end
