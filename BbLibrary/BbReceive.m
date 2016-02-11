//
//  BbReceive.m
//  Pods
//
//  Created by Travis Henspeter on 1/30/16.
//
//

#import "BbReceive.h"

@interface BbReceive ()

@property (nonatomic,strong)                    NSString        *myNotificationName;

@end

@implementation BbReceive

@synthesize parent = parent_;

- (void)setupPorts
{
    BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
}

- (void)receiveNotification:(NSNotification *)notification
{
    id value = notification.object;
    [[self.outlets firstObject]setInputElement:value];
}

- (void)setParent:(id<BbEntity,BbObject>)parent
{
    parent_ = parent;
    if (parent) {
        [self subscribeToNotificationsWithParentID:[parent uniqueID]];
    }
}

- (void)subscribeToNotificationsWithParentID:(NSString *)parentID
{
    NSString *parentIdProxy = @"$0";
    NSString *notificationName = self.creationArguments;
    NSRange proxyRange = [notificationName rangeOfString:parentIdProxy];
    if ( [notificationName hasPrefix:parentIdProxy] ) {
        NSString *textCopy = notificationName.copy;
        notificationName = [textCopy stringByReplacingCharactersInRange:proxyRange withString:parentID];
    }
    
    self.myNotificationName = notificationName;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:self.myNotificationName object:nil];
}

- (void)cleanup
{
    if (self.myNotificationName) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:self.myNotificationName object:nil];
        self.myNotificationName = nil;
    }
}

+ (NSString *)symbolAlias
{
    return @"re";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"r";
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
}



@end
