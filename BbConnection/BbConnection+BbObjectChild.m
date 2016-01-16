//
//  BbConnection+BbObjectChild.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbConnection.h"
#import "BbBridge.h"

@implementation BbConnection (BbObjectChild)

- (NSUInteger)indexInParent
{
    if ( nil == self.parent ) {
        return BbIndexInParentNotFound;
    }
    
    return [self.parent indexOfChildObject:self];
}

- (NSString *)textDescription
{
    NSUInteger senderIndex = [self.sender indexInParent];
    NSUInteger receiverIndex = [self.receiver indexInParent];
    NSUInteger senderParentIndex = [self.parent indexOfChildObject:[self.sender parent]];
    NSUInteger receiverParentIndex = [self.parent indexOfChildObject:[self.receiver parent]];
    NSString *className = NSStringFromClass([self class]);
    NSString *token = @"#X";
    NSString *description = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@;\n",token,className,@(senderParentIndex),@(senderIndex),@(receiverParentIndex),@(receiverIndex)];
    return description;
}

@end
