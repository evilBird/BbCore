//
//  BbPatchContentView.m
//  Pods
//
//  Created by Travis Henspeter on 1/21/16.
//
//

#import "BbPatchContentView.h"
#import "BbCoreViewProtocols.h"

@interface BbPatchContentView ()

@property (nonatomic,strong)    NSArray         *connectionPaths;

@end

@implementation BbPatchContentView

- (void)drawConnectionPaths:(NSArray *)paths
{
    self.connectionPaths = paths;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if ( nil != self.connectionPaths ) {
        
        for (id<BbConnectionPath> aPath in self.connectionPaths ) {
            
            UIBezierPath *bezierPath = [aPath bezierPath];
            [bezierPath setLineWidth:6];
            [[UIColor blackColor]setStroke];
            [bezierPath stroke];
            
        }
    }
    
    if ( nil != self.activePath ) {
        self.activePath.lineWidth = 8;
        [self.activePath stroke];
    }
}


@end
