//
//  BbOutlet.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbPort.h"

@interface BbOutlet : BbPort

@property (nonatomic,strong)        NSMutableArray          *strongConnections;

@end

@interface BbOutlet (BbEntityProtocol) <BbEntity>

+ (NSString *)viewClass;

- (NSSet *)childConnections;

- (BOOL)addChildEntity:(id<BbEntity>)entity;

- (BOOL)removeChildEntity:(id<BbEntity>)entity;

- (BOOL)isParentOfEntity:(id<BbEntity>)entity;

@end