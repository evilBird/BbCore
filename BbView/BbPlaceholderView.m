//
//  BbPlaceholderView.m
//  Pods
//
//  Created by Travis Henspeter on 1/26/16.
//
//

#import "BbPlaceholderView.h"

@implementation BbPlaceholderView

- (instancetype)initWithPosition:(NSValue *)position
{
    self = [super initWithEntity:nil];
    self.position = position;
    return self;
}


@end
