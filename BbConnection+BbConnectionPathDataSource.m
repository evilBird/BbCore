//
//  BbConnection+BbConnectionPathDataSource.m
//  Pods
//
//  Created by Travis Henspeter on 1/11/16.
//
//

#import "BbConnection.h"

@implementation BbConnection (BbConnectionPathDataSource)

- (NSValue *)originPointForConnectionPath:(id<BbConnectionPath>)connectionPath
{
    return nil;
}

- (NSValue *)terminalPointForConnectionPath:(id<BbConnectionPath>)connectionPath
{
    return nil;
}

@end
