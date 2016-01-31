//
//  BbAbstraction.h
//  Pods
//
//  Created by Travis Henspeter on 1/27/16.
//
//

#import "BbObject.h"

@interface BbAbstraction : BbObject

+ (NSString *)emptyAbstractionDescription;

- (id<BbPatchView>)open;
- (void)close;

@end
