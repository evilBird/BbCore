//
//  BbPort+BbObjectChild.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPort.h"

@implementation BbPort (BbObjectChild)

#pragma mark - BbChildObject

- (NSUInteger)indexInParent
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildObject:self];
}

@end
