//
//  BbPatch.m
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatch.h"

@implementation BbPatch

- (NSString *)myToken
{
    return @"#N";
}

- (NSString *)myViewClass
{
    if ( nil != self.viewClass ) {
        return self.viewClass;
    }
    
    return @"BbPatchView";
}

- (NSString *)textDescription
{
    NSString *text = [super textDescription];
    return [text stringByAppendingString:[self selectorText]];
}

- (NSString *)selectorText
{
    if ( nil == self.mySelectors ) {
        return @"";
    }
    NSMutableString *selectors = [NSMutableString string];
    NSString *depthString = nil;
    if ( nil != self.parent ) {
        depthString = [self.parent depthStringForChildObject:self];
    }else{
        depthString = @"";
    }
    for (NSString *aSelectorDescription in self.mySelectors ) {
        [selectors appendFormat:@"%@#S %@;\n",depthString,aSelectorDescription];
    }
    
    return selectors;
}

- (void)doSelectors
{
    NSLog(@"DOING MY SELECTORS: %@",self.mySelectors);
}

@end
