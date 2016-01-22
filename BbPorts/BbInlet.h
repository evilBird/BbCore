//
//  BbInlet.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPort.h"

@class BbOutlet;

@interface BbInlet : BbPort

@property   (nonatomic,strong)         NSHashTable                       *weakConnections;
@property   (nonatomic,getter=isHot)   BOOL                              hot;

@end

@interface BbInlet (BbEntityProtocol) <BbEntity>

+ (NSString *)viewClass;

- (NSSet *)childConnections;

- (BOOL)addChildEntity:(id<BbEntity>)entity;

- (BOOL)removeChildEntity:(id<BbEntity>)entity;

- (BOOL)isParentOfEntity:(id<BbEntity>)entity;

@end