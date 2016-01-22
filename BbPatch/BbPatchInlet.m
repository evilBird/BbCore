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

- (NSArray *)loadChildViews
{
    NSMutableArray *childViews = [NSMutableArray arrayWithCapacity:(self.inlets.count+self.outlets.count)];

    for (id<BbEntity> outlet in self.outlets) {
        id<BbEntityView> outletView = [outlet loadView];
        outlet.view = outletView;
        outletView.entity = outlet;
        [childViews addObject:outletView];
    }
    return childViews;
}

@end
