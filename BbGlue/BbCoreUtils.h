//
//  BbCoreUtils.h
//  Pods
//
//  Created by Travis Henspeter on 1/19/16.
//
//

#import <Foundation/Foundation.h>

@interface BbCoreUtils : NSObject


@end


@interface NSString (BbCoreUtils)

+ (NSString *)uniqueIDString;

- (NSString *)trimWhitespace;

- (NSArray *)getComponents;

- (NSArray *)getArguments;

- (NSUInteger)numberOfArguments;

- (id)getArgumentAtIndex:(NSUInteger)index;

- (NSString *)setArgument:(id)argument atIndex:(NSUInteger)index;

@end

@interface NSArray (BbCoreUtils)

- (NSString *)getString;

@end