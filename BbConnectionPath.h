//
//  BbConnectionPath.h
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#ifndef BbConnectionPath_h
#define BbConnectionPath_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BbConnectionPath <NSObject>

- (id<BbConnectionPath>)connectionPathWithOriginPoint:(NSValue *)originPoint terminalPoint:(NSValue *)terminalPoint;

- (void)setOriginPoint:(NSValue *)originPoint;
- (void)setTerminalPoint:(NSValue *)terminalPoint;
- (void)removeFromParentView;

@end

#endif /* BbConnectionPath_h */
