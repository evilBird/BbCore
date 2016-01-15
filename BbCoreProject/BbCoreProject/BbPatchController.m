//
//  BbPatchController.m
//  BbBridge
//
//  Created by Travis Henspeter on 1/12/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatchController.h"
#import "BbPatch.h"
#import "BbPatchView.h"
#import "BbParseText.h"
#import "BbBridge.h"
#import "BbScrollView.h"
#import "BbPatchViewContainer.h"

@interface BbPatchController ()

@property (nonatomic,strong)        BbPatchDescription      *myPatchDescription;
@property (nonatomic,strong)        BbPatchViewContainer    *myPatchContainer;

@end

@implementation BbPatchController

- (instancetype)initWithText:(NSString *)text delegate:(id<BbPatchControllerDelegate>)delegate
{
    self = [super init];
    if ( self ) {
        _delegate = delegate;
        _myPatchText = text;
    }
    
    return self;
}

- (void)loadPatchCompletion:(void(^)(void))completion
{
    self.myPatchDescription = [BbParseText parseText:self.myPatchText];
    self.myPatch = [BbPatch patchWithDescription:self.myPatchDescription];
    completion();
}

- (void)loadViewsCompletion:(void(^)(void))completion
{
    BOOL success = [self.myPatch loadViews];
    self.myPatchContainer = [[BbPatchViewContainer alloc]initWithPatchView:(BbPatchView *)self.myPatch.view];
    self.myPatchContainer.backgroundColor = [UIColor greenColor];
    NSAssert(success, @"ERROR LOADING PATCH VIEWS");
    [self.delegate addObjectView:self.myPatchContainer];
    [self.myPatch.view updateLayout];
    completion();
}

@end
