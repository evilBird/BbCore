//
//  BbObject+BbObjectViewDataSource.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbObject.h"

@implementation BbObject (BbObjectViewDataSource)

#pragma mark - BbObjectViewDataSource


- (NSUInteger)numberOfInletsForObjectView:(id<BbObjectView>)objectView
{
    return self.myInlets.count;
}

- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView
{
    return self.myOutlets.count;
}

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView
{
    NSMutableArray *words = [NSMutableArray array];
    
    if ( nil != self.objectClass ) {
        [words addObject:self.objectClass];
    }else{
        [words addObject:NSStringFromClass([self class])];
    }
    
    if ( nil != self.objectArguments ) {
        [words addObject:self.objectArguments];
    }
    
    return [words componentsJoinedByString:@" "];
}

- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView
{
    if ( nil == self.viewArguments ) {
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    NSArray *args = [self.viewArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ( nil == args || args.count != 2 ) {
        return [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    }
    
    CGFloat xoffset = [args.firstObject doubleValue];
    CGFloat yoffset = [args.lastObject doubleValue];
    return [NSValue valueWithCGPoint:CGPointMake(xoffset, yoffset)];
}

- (void)objectView:(id<BbObjectView>)sender positionDidChange:(NSValue *)position
{
    CGPoint point = position.CGPointValue;
    self.viewArguments = [NSString stringWithFormat:@"%.4f %.4f",point.x,point.y];
}

- (void)objectView:(id<BbObjectView>)sender objectArgumentsDidChange:(NSString *)arguments
{
    self.objectArguments = arguments;
}

@end
