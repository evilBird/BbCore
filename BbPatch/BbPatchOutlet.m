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
    inlet.hot = YES;
    [self addChildEntity:inlet];
    
    __block BbOutlet *outlet = [[BbOutlet alloc]init];
    [self addChildEntity:outlet];
    __block id outputValue;
    [inlet setOutputBlock:^(id value){
        outputValue = value;
        outlet.inputElement = outputValue;
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

- (NSArray *)loadChildViews
{
    NSMutableArray *childViews = [NSMutableArray arrayWithCapacity:(self.inlets.count+self.outlets.count)];
    
    for (id<BbEntity> inlet in self.inlets ) {
        id<BbEntityView> inletView = [inlet loadView];
        inlet.view = inletView;
        inletView.entity = inlet;
        [childViews addObject:inletView];
    }
    
    return childViews;
}
@end
