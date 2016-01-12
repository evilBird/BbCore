//
//  BbConnectionDelegate.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbConnectionDelegate_h
#define BbConnectionDelegate_h

#import "BbObjectRelationshipDefs.h"

@class BbPort;

@protocol BbConnectionDelegate <NSObject,BbObjectChild>


- (BOOL)hasConnection:(id)sender;
- (BOOL)makeConnection:(id)sender withElement:(NSUInteger)element ofPort:(BbPort *)port;
- (BOOL)removeConnection:(id)sender withElement:(NSUInteger)element ofPort:(BbPort *)port;

@end

#endif /* BbConnectionDelegate_h */
