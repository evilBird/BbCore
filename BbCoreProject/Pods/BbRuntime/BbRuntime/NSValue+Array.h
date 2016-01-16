//
//  NSValue+Array.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/4/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSValue (Array)

- (NSUInteger)getMemberCount;
- (NSArray *)valueArray;
- (NSValue *)valueWithArray:(NSArray *)array;
+ (NSValue *)valueWithArray:(NSArray *)array objCType:(const char *)type;

@end
