//
//  BbPatchOutlet.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchOutlet.h"

@implementation BbPatchOutlet

- (void)setupPorts
{
    BbInlet *inlet = [[BbInlet alloc]init];
    inlet.hotInlet = YES;
    [self addChildObject:inlet];
    
    __block BbOutlet *outlet = [[BbOutlet alloc]init];
    [self addChildObject:outlet];
    
    [inlet setOutputBlock:^(id value){
        outlet.inputElement = value;
    }];
    
}

+ (NSString *)viewClass
{
    return @"BbPatchOutletView";
}

+ (NSString *)symbolAlias
{
    return @"outlet";
}

- (NSUInteger)numberOfInletsForObjectView:(id<BbObjectView>)objectView
{
    return self.inlets.count;
}

- (NSUInteger)numberOfOutletsForObjectView:(id<BbObjectView>)objectView
{
    return 0;
}

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView
{
    return @"";
}


@end
