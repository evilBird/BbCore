//
//  BbCloseBang.m
//  Pods
//
//  Created by Travis Henspeter on 1/30/16.
//
//

#import "BbCloseBang.h"

@implementation BbCloseBang

- (void)receiveNotification:(NSNotification *)notification
{
    id value = notification.object;
    [[self.outlets firstObject]setInputElement:value];
}

- (void)commonInit
{
    [super commonInit];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadBang) name:kLoadBangNotification object:nil];
}

- (void)loadBang
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kLoadBangNotification object:nil];
    
    if (!self.parent) {
        return;
    }
    
    NSString *parentID = [self.parent uniqueID];
    NSString *closeBangNotificationName = [NSString stringWithFormat:@"%@-%@",parentID,kCloseBangNotification];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:closeBangNotificationName object:nil];
}

- (void)closeBang
{
    if (!self.parent) {
        return;
    }
    
    NSString *parentID = [self.parent uniqueID];
    NSString *closeBangNotificationName = [NSString stringWithFormat:@"%@-%@",parentID,kCloseBangNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:closeBangNotificationName object:nil];
}

@end
