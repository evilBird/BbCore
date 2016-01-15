//
//  BbPatchController.h
//  BbBridge
//
//  Created by Travis Henspeter on 1/12/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BbPatchControllerDelegate <NSObject>

- (void)addObjectView:(id)objectView;

@end

@class BbPatch;

@interface BbPatchController : NSObject

@property (nonatomic,strong)        NSString                        *myPatchText;
@property (nonatomic,strong)        BbPatch                         *myPatch;
@property (nonatomic,weak)          id<BbPatchControllerDelegate>   delegate;

- (instancetype)initWithText:(NSString *)text delegate:(id<BbPatchControllerDelegate>)delegate;
- (void)loadPatchCompletion:(void(^)(void))completion;
- (void)loadViewsCompletion:(void(^)(void))completion;

@end
