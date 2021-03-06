//
//  BbPatch.h
//  BbObject
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"
#import "BbConnection.h"
#import "BbSymbolTable.h"
#import "BbPatchInlet.h"
#import "BbPatchOutlet.h"
#import "BbTextDescription.h"

@class BbPatchDescription;
@class BbSymbolTable;
@class BbAbstraction;

@interface BbPatch : BbObject

@property (nonatomic,strong)                NSMutableArray                                      *selectors;
@property (nonatomic,strong)                NSMutableArray                                      *objects;
@property (nonatomic,strong)                NSHashTable                                         *loadBangObjects;
@property (nonatomic,strong)                NSHashTable                                         *closeBangObjects;
@property (nonatomic,strong)                NSUndoManager                                       *undoManager;
@property (nonatomic,strong)                BbSymbolTable<BbTextCompletionDataSource>           *symbolTable;
@property (nonatomic,strong)                NSArray                                             *childArguments;
@property (nonatomic)                       BOOL                                                canUndo;
@property (nonatomic)                       BOOL                                                canRedo;

- (void)doSelectors;
- (void)loadBang;
- (void)closeBang;
- (void)updateUndoManagerState;
- (NSString *)makeSubstitutionsInChildArgs:(NSString *)childArgs;

@end

@interface BbPatch (BbEntityProtocol) <BbEntity>

- (BOOL)isParentOfEntity:(id<BbEntity>)entity;

- (BOOL)addChildEntity:(id<BbEntity>)entity;

- (BOOL)insertChildEntity:(id<BbEntity>)entity atIndex:(NSUInteger)index;

- (BOOL)removeChildEntity:(id<BbEntity>)entity;

- (NSUInteger)indexOfChildEntity:(id<BbEntity>)entity;

- (BOOL)replaceChildEntity:(id<BbEntity>)entityToReplace withEntity:(id<BbEntity>)replacementEntity;

- (NSString *)textDescription;

- (NSString *)textDescriptionToken;

- (NSString *)depthStringForChild:(id<BbEntity>)entity;

- (NSSet *)childConnections;

@end

@interface BbPatch (BbObjectProtocol) <BbObject>


+ (NSString *)symbolAlias;

- (id<BbPatchView>)loadView;

- (void)unloadView;

- (BOOL)objectView:(id<BbObjectView>)sender didChangeValue:(NSValue *)value forViewArgumentKey:(NSString *)key;

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)sender;

- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender;

- (void)objectView:(id<BbObjectView>)sender didBeginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)editingDelegate;

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText;

@end

@interface BbPatch (BbPatchProtocol) <BbPatch>

- (BbPatchDescription *)patchDescription;

- (NSArray *)loadChildViews;

- (NSArray *)loadChildConnectionPaths;

- (void)unloadChildViews;

- (void)unloadChildConnectionPaths;

- (void)pasteCopiedWithText:(NSString *)text;

- (void)abstractCopiedWithText:(NSString *)text;

- (void)insertAbstraction:(BbAbstraction *)abstraction atPosition:(NSValue *)position;

- (void)insertAbstractionWithText:(NSString *)text atPosition:(NSValue *)position restoreConnections:(NSString *)connectionsText cutSelected:(BOOL)cutSelected;

- (void)patchView:(id<BbPatchView>)sender didConnectOutletView:(id<BbEntityView>)outletView toInletView:(id<BbEntityView>)inletView;

- (void)patchView:(id<BbPatchView>)sender didAddPlaceholderObjectView:(id<BbObjectView>)objectView;

- (void)patchView:(id<BbPatchView>)sender didAddChildEntityView:(id<BbObjectView>)objectView;

- (void)patchView:(id<BbPatchView>)sender didAddChildConnection:(id<BbConnection>)connection;

- (void)patchView:(id<BbPatchView>)sender didRemoveChildConnection:(id<BbConnection>)connection;

- (void)patchView:(id<BbPatchView>)sender didRemoveChildObjectView:(id<BbObjectView>)objectView;

@end

@interface BbPatch (BbObjectViewEditingDelegate) <BbObjectViewEditingDelegate>

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText;

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithUserText:(NSString *)userText;

@end

@interface BbPatch (Meta)

+ (BbPatch *)objectWithDescription:(BbPatchDescription *)description dataSource:(id<BbObjectDataSource>)dataSource;

- (BbConnection *)connectionWithDescription:(BbConnectionDescription *)description;

+ (BbConnection *)connectionWithDecription:(BbConnectionDescription *)description amongstCopiedObjects:(NSArray *)objects;

@end