//
//  BbObject+BbObjectChild.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbObject.h"

@implementation BbObject (BbObjectChild)

- (NSUInteger)indexInParent
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildObject:self];
}

@end
