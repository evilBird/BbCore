//
//  BbPatchInlet.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchInlet.h"

@implementation BbPatchInlet

- (void)setupPorts
{
    BbInlet *inlet = [[BbInlet alloc]init];
    inlet.hot = YES;
    [self addChildEntity:inlet];
    
    __block BbOutlet *outlet = [[BbOutlet alloc]init];
    [self addChildEntity:outlet];
    
    [inlet setOutputBlock:^(id value){
        outlet.inputElement = value;
    }];
    
}

+ (NSString *)symbolAlias
{
    return @"inlet";
}

+ (NSString *)viewClass
{
    return @"BbPatchInletView";
}

- (NSUInteger)numberOfInletsForObjectView:(id<BbObjectView>)objectView
{
    return 0;
}

- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView
{
    return self.outlets.count;
}

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView
{
    return @"";
}

@end
