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

@protocol BbConnectionPath;

@protocol BbConnectionPathDataSource <NSObject>

- (UIView *)getSendingView:(id<BbConnectionPath>)sender;

- (UIView *)getReceivingView:(id<BbConnectionPath>)sender;

- (NSString *)connectionIDForConnectionPath:(id<BbConnectionPath>)connectionPath;

- (NSValue *)originPointForConnectionPath:(id<BbConnectionPath>)connectionPath;

- (NSValue *)terminalPointForConnectionPath:(id<BbConnectionPath>)connectionPath;

@end

@protocol BbConnectionPathDelegate <NSObject>

@optional
- (void)redrawConnectionPath:(id<BbConnectionPath>)connectionPath;

- (void)addConnectionPath:(id<BbConnectionPath>)connectionPath;

- (void)removeConnectionPath:(id<BbConnectionPath>)connectionPath;

@end

@protocol BbConnectionPath <NSObject>

- (void)setOriginPoint:(NSValue *)originPoint;

- (void)setTerminalPoint:(NSValue *)terminalPoint;

- (void)setNeedsRedraw:(BOOL)redraw;

- (void)setIsOrphan:(BOOL)isOrphan;

- (void)removeFromParentView;

- (UIView *)sendingView;

- (UIView *)receivingView;

@end

@interface BbConnectionPath : NSObject <BbConnectionPath>

@property (nonatomic, readonly)             NSString                            *connectionID;

@property (nonatomic, readonly)             NSString                            *senderID;

@property (nonatomic, readonly)             NSString                            *receiverID;

@property (nonatomic, readonly)             NSString                            *parentID;

@property (nonatomic, weak)                 id<BbConnectionPathDelegate>        delegate;

@property (nonatomic, weak)                 id<BbConnectionPathDataSource>      dataSource;

@property (nonatomic, readonly)             UIBezierPath                        *bezierPath;

@property (nonatomic)                       BOOL                                needsRedraw;

@property (nonatomic)                       BOOL                                isOrphan;

@property (nonatomic,getter=isSelected)     BOOL                                selected;

@property (nonatomic,readonly)              UIColor                             *preferredColor;

@property (nonatomic)                       NSValue                             *originPoint;

@property (nonatomic,strong)                NSValue                             *terminalPoint;

@property (nonatomic)                       CGPoint                             origin;

@property (nonatomic)                       CGPoint                             terminus;


+ (BbConnectionPath *)addConnectionPathWithDelegate:(id<BbConnectionPathDelegate>)delegate dataSource:(id<BbConnectionPathDataSource>)dataSource;

- (instancetype)initWithDelegate:(id<BbConnectionPathDelegate>)delegate dataSource:(id<BbConnectionPathDataSource>)dataSource;

@end

#endif /* BbConnectionPath_h */
