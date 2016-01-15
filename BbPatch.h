//
//  BbPatch.h
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbConnection.h"

@class BbPatchDescription;

@interface BbPatch : BbObject

@property (nonatomic,strong)                NSMutableArray                          *mySelectors;
@property (nonatomic,strong)                NSMutableArray                          *childObjects;
@property (nonatomic,strong)                NSMutableArray                          *connections;


@end

@interface BbPatch (BbObjectParent) <BbObjectParent>

- (NSString *)depthStringForChildObject:(id<BbObjectChild>)child;

- (void)didAddChildConnection:(BbConnection *)connection;

- (void)didRemoveChildConnection:(BbConnection *)connection;

- (void)doSelectors;

- (NSString *)selectorText;

- (NSString *)textDescription;

- (NSString *)descriptionToken;

- (BOOL)loadViews;

@end

@interface BbPatch (BbObjectViewDelegate) <BbObjectViewEditingDelegate>

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)objectView;

- (void)objectView:(id<BbObjectView>)objectView didEditText:(NSString *)text;

- (BOOL)objectView:(id<BbObjectView>)objectView shouldEndEditingWithText:(NSString *)text;

- (void)objectViewDidAppear:(id<BbObjectView>)sender;

- (void)objectView:(id<BbObjectView>)sender didChangePosition:(NSValue *)position;

- (void)objectView:(id<BbObjectView>)sender didChangeContentOffset:(NSValue *)offset;

- (void)objectView:(id<BbObjectView>)sender didChangeZoomScale:(NSValue *)zoomScale;

- (void)objectView:(id<BbObjectView>)sender didChangeSize:(NSValue *)viewSize;

- (void)objectView:(id<BbObjectView>)sender didRequestPlaceholderViewAtPosition:(NSValue *)position;

@end

@interface BbPatch (BbObjectViewDataSource)

- (NSValue *)contentOffsetForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)zoomScaleForObjectView:(id<BbObjectView>)objectView;

- (NSValue *)sizeForObjectView:(id<BbObjectView>)objectView;

@end

@interface BbPatch (Meta)

+ (BbPatch *)patchWithDescription:(BbPatchDescription *)description;

+ (BbObject *)objectWithDescription:(BbObjectDescription *)description;

- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description;

@end