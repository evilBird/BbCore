//
//  BbBangObject.m
//  Pods
//
//  Created by Travis Henspeter on 1/28/16.
//
//

#import "BbBangObject.h"

@implementation BbBangObject

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    __block BbOutlet *outlet = [[BbOutlet alloc]init];
    [self addChildEntity:outlet];
    
    __weak BbBangObject *weakself = self;
    [hotInlet setOutputBlock:^(id value){
        [weakself.view setHighlighted:YES];
        outlet.inputElement = [BbBang bang];
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.displayText = @"";
    self.name = @"bang";
}

+ (NSString *)symbolAlias
{
    return @"b";
}

+ (NSString *)viewClass
{
    return @"BbBangView";
}

- (void)sendActionsForView:(id<BbObjectView>)sender
{
    [self.inlets[0] setInputElement:[BbBang bang]];
}

- (BOOL)canEdit
{
    return NO;
}

- (BOOL)canOpen
{
    return NO;
}

@end
