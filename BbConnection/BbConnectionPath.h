//
//  BbConnectionPath.h
//  Pods
//
//  Created by Travis Henspeter on 1/21/16.
//
//

#import <Foundation/Foundation.h>
#import "BbCoreProtocols.h"

@interface BbConnectionPath : NSObject <BbConnectionPath>

@property (nonatomic,weak)                      id<BbEntity,BbConnection>                           entity;
@property (nonatomic,getter=isSelected)         BOOL                                                selected;
@property (nonatomic,getter=isValid)            BOOL                                                valid;
@property (nonatomic)                           BOOL                                                needsRedraw;

@property (nonatomic,strong)                    NSValue                                             *startPoint;
@property (nonatomic,strong)                    NSValue                                             *endPoint;

@property (nonatomic,readonly)                  id                                                  bezierPath;
@property (nonatomic,readonly)                  id                                                  color;

- (NSValue *)centerPointValueForEntityView:(id<BbEntityView>)view inParentView:(id<BbEntityView>)parentView;

@end
