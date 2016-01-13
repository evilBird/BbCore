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

- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView
{
    return [BbHelpers positionFromViewArgs:self.viewArguments];
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


@end
