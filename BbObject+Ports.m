//
//  BbObject+Ports.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"

@implementation BbObject (Ports)

#pragma mark - Port management & accessors

- (void)setupDefaultPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hotInlet = YES;
    [self addChildObject:hotInlet];
    BbInlet *coldInlet = [[BbInlet alloc]init];
    [self addChildObject:coldInlet];
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildObject:mainOutlet];
    hotInlet.outputBlock = ^(id value){
        mainOutlet.inputElement = value;
    };
}

- (void)didAddChildPort:(BbPort *)childPort
{
    
}

- (void)didRemoveChildPort:(BbPort *)childPort
{
    
}

@end
