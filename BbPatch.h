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

@end

@interface BbPatch (Connections)

- (void)didAddChildConnection:(BbConnection *)connection;
- (void)didRemoveChildConnection:(BbConnection *)connection;

@end

@interface BbPatch (Ports)

- (void)setupDefaultPorts;
- (void)didAddChildPort:(BbPort *)childPort;
- (void)didRemoveChildPort:(BbPort *)childPort;

@end

@interface BbPatch (BbObjectViewDataSource)

- (NSValue *)contentOffsetForObjectView:(id<BbObjectView>)objectView;
- (NSValue *)zoomScaleForObjectView:(id<BbObjectView>)objectView;
- (NSValue *)sizeForObjectView:(id<BbObjectView>)objectView;

- (void)objectView:(id<BbObjectView>)sender objectClassDidChange:(NSString *)objectClass arguments:(NSString *)arguments;
- (void)objectView:(id<BbObjectView>)sender doAction:(id)anAction withArguments:(id)arguments;
- (void)objectView:(id<BbObjectView>)sender contentOffsetDidChange:(NSValue *)offset;
- (void)objectView:(id<BbObjectView>)sender zoomScaleDidChange:(NSValue *)zoomScale;
- (void)objectView:(id<BbObjectView>)sender sizeDidChange:(NSValue *)viewSize;
- (void)objectView:(id<BbObjectView>)sender viewForPort:(id)port didMoveToIndex:(NSUInteger)index;

@end

@interface BbPatch (Meta)

+ (BbPatch *)patchWithDescription:(BbPatchDescription *)description;

@end