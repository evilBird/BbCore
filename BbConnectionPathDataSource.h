//
//  BbConnectionPathDataSource.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbConnectionPathDataSource_h
#define BbConnectionPathDataSource_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BbConnectionPath;

@protocol BbConnectionPathDataSource <NSObject>

- (NSValue *)originPointForConnectionPath:(id<BbConnectionPath>)connectionPath;
- (NSValue *)terminalPointForConnectionPath:(id<BbConnectionPath>)connectionPath;

@end

#endif /* BbConnectionPathDataSource_h */
