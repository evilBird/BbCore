//
//  BbPatch.h
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"

@class BbPatchDescription;

@interface BbPatch : BbObject

@property (nonatomic,strong)            NSMutableArray      *mySelectors;

- (void)doSelectors;

@end

@interface BbPatch (Connections) <BbConnectionPathDelegate>

- (void)didAddChildConnection:(BbConnection *)connection;

- (void)didRemoveChildConnection:(BbConnection *)connection;

@end

@interface BbPatch (Ports)

- (void)setupDefaultPorts;

- (void)didAddChildPort:(BbPort *)childPort;

- (void)didRemoveChildPort:(BbPort *)childPort;

@end

@interface BbPatch (BbObjectViewDelegate)

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
- (BOOL)loadViews;

@end