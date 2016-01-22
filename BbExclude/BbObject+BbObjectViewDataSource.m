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
    return self.inlets.count;
}

- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView
{
    return self.outlets.count;
}

- (NSValue *)positionForObjectView:(id<BbObjectView>)objectView
{
    return [BbHelpers positionFromViewArgs:self.viewArguments];
}

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView
{
    NSMutableArray *words = [NSMutableArray array];
        
    if ( nil != self.name ) {
        [words addObject:self.name];
    }else if ( [[self class] symbolAlias] ){
        NSString *alias = [[self class]symbolAlias];
        [words addObject:alias];
    }else{
        NSString *className = NSStringFromClass([self class]);
        [words addObject:className];
    }
    
    if ( nil != self.objectArguments ) {
        [words addObjectsFromArray:[self.objectArguments componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    
    self.displayText = [words componentsJoinedByString:@" "];
    return self.displayText;
}


@end
