//
//  BbProtocols.h
//  Pods
//
//  Created by Travis Henspeter on 1/19/16.
//
//

#ifndef BbProtocols_h
#define BbProtocols_h

#import "BbCoreViewProtocols.h"

@protocol BbEntity <NSObject>

@property (nonatomic,strong)        NSString                    *uniqueID;
@property (nonatomic,strong)        NSHashTable                 *entityObservers;
@property (nonatomic,weak)          id<BbEntity,BbObject>       parent;

- (BOOL)addEntityObserver:(id<BbEntity>)entity;

- (BOOL)removeEntityObserver:(id<BbEntity>)entity;

- (BOOL)startObservingEntity:(id<BbEntity>)entity;

- (BOOL)stopObservingEntity:(id<BbEntity>)entity;

- (BOOL)removeAllEntityObservers;

- (BOOL)isChildOfEntity:(id<BbEntity>)entity;

- (NSUInteger)indexInParentEntity;

@optional

@property (nonatomic,strong)        id<BbEntityView>            view;

- (BOOL)isParentOfEntity:(id<BbEntity>)entity;

- (BOOL)addChildEntity:(id<BbEntity>)entity;

- (BOOL)insertChildEntity:(id<BbEntity>)entity atIndex:(NSUInteger)index;

- (BOOL)removeChildEntity:(id<BbEntity>)entity;

- (NSUInteger)indexOfChildEntity:(id<BbEntity>)entity;

- (BOOL)replaceChildEntity:(id<BbEntity>)entityToReplace withEntity:(id<BbEntity>)replacementEntity;

- (NSString *)textDescription;

- (NSString *)textDescriptionToken;

- (NSString *)depthStringForChild:(id<BbEntity>)entity;

@end

@protocol BbObject <NSObject,BbEntity>

@property (nonatomic,strong)    id<BbEntityView,BbObjectView>           view;
@property (nonatomic,weak)      id<BbEntity,BbObject,BbPatch>           parent;

@property (nonatomic,strong)    NSString                        *creationArguments;
@property (nonatomic,strong)    NSString                        *viewArguments;

@property (nonatomic,strong)    NSMutableArray                  *inlets;
@property (nonatomic,strong)    NSMutableArray                  *outlets;

@property (nonatomic,strong)    NSString                        *displayText;
@property (nonatomic,strong)    NSString                        *userText;

+ (NSString *)symbolAlias;

- (id<BbObjectView>)loadView;

- (void)unloadView;

- (BOOL)objectView:(id<BbObjectView>)sender didChangeValue:(NSValue *)value forViewArgumentKey:(NSString *)key;

@optional

- (BOOL)objectViewShouldBeginEditing:(id<BbObjectView>)sender;

- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender;

- (void)objectView:(id<BbObjectView>)sender didBeginEditingWithDelegate:(id<BbObjectViewEditingDelegate>)editingDelegate;

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText;

@end

@protocol BbConnection <NSObject,BbEntity>

@property (nonatomic,weak)                      id<BbEntity, BbObject, BbPatch>                                     parent;
@property (nonatomic,weak)                      id<BbEntity>                                                        sender;
@property (nonatomic,weak)                      id<BbEntity>                                                        receiver;

@property (nonatomic,getter=isSelected)         BOOL                                                                selected;
@property (nonatomic,getter=isValid)            BOOL                                                                valid;
@property (nonatomic,strong)                    id                                                                  path;

- (id)loadPath;
- (void)unloadPath;

@end


@protocol BbPatch <NSObject,BbEntity,BbObject>

@property (nonatomic,strong)    id<BbEntityView,BbObjectView,BbPatchView>       view;

@property (nonatomic,strong)    NSMutableArray                                  *objects;
@property (nonatomic,strong)    NSMutableArray                                  *connections;
@property (nonatomic,strong)    NSMutableArray                                  *selectors;

- (id<BbPatchView>)loadView;

- (NSArray *)loadChildViews;

- (void)unloadChildViews;

- (NSArray *)loadChildConnections;

- (void)unloadChildConnections;

- (void)patchView:(id<BbPatchView>)sender didConnectOutletView:(id<BbEntityView>)outletView toInletView:(id<BbEntityView>)inletView;

- (void)patchView:(id<BbPatchView>)sender didAddPlaceholderObjectView:(id<BbObjectView>)objectView;

- (void)patchView:(id<BbPatchView>)sender didAddChildObjectView:(id<BbObjectView>)objectView;

- (void)patchView:(id<BbPatchView>)sender didAddChildConnection:(id<BbConnection>)connection;

- (void)patchView:(id<BbPatchView>)sender didRemoveChildConnection:(id<BbConnection>)connection;

- (void)patchView:(id<BbPatchView>)sender didRemoveChildObjectView:(id<BbObjectView>)objectView;


@end

#endif /* BbProtocols_h */
