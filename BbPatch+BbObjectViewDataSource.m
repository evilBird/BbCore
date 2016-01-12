//
//  BbPatch+BbObjectViewDataSource.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPatch.h"

@implementation BbPatch (BbObjectViewDataSource)

- (NSValue *)contentOffsetForObjectView:(id<BbObjectView>)objectView
{
    if ( nil != self.viewArguments ) {
        NSArray *args = [self.viewArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( args.count > 4 ) {
            NSString *xoffsetString = args[3];
            NSString *yoffsetString = args[4];
            double xOffset = [xoffsetString doubleValue];
            double yOffset = [yoffsetString doubleValue];
            return [NSValue valueWithCGPoint:CGPointMake(xOffset, yOffset)];
        }
    }
    
    return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
}

- (NSValue *)zoomScaleForObjectView:(id<BbObjectView>)objectView
{
    if ( nil != self.viewArguments ) {
        NSArray *args = [self.viewArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( args.count == 5 ) {
            NSString *zoomString = args.lastObject;
            double zoom = [zoomString doubleValue];
            return (NSValue *)[NSNumber numberWithDouble:zoom];
        }
    }
    
    return (NSValue *)[NSNumber numberWithDouble:1.0];
}

- (NSValue *)sizeForObjectView:(id<BbObjectView>)objectView
{
    if ( nil != self.viewArguments ) {
        NSArray *args = [self.viewArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ( args.count > 2 ) {
            NSString *widthArgString = args[0];
            NSString *heightArgString = args[1];
            double width = [widthArgString doubleValue];
            double height = [heightArgString doubleValue];
            return (NSValue *)[NSValue valueWithCGSize:CGSizeMake(width, height)];
        }
    }
    
    return [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
}

- (void)objectView:(id<BbObjectView>)sender objectClassDidChange:(NSString *)objectClass arguments:(NSString *)arguments
{
    
}

- (void)objectView:(id<BbObjectView>)sender doAction:(id)anAction withArguments:(id)arguments
{
    
}

- (void)objectView:(id<BbObjectView>)sender contentOffsetDidChange:(NSValue *)offset
{
    
}

- (void)objectView:(id<BbObjectView>)sender zoomScaleDidChange:(NSValue *)zoomScale
{
    
}

- (void)objectView:(id<BbObjectView>)sender sizeDidChange:(NSValue *)viewSize
{
    
}

- (void)objectView:(id<BbObjectView>)sender viewForPort:(id)port didMoveToIndex:(NSUInteger)index
{
    
}

@end
