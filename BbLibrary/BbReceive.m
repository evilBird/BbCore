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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeBang) name:closeBangNotificationName object:nil];
    if (!self.myNotificationName) {
        NSString *text = self.creationArguments;
        NSRange parentIdRange = [(NSString *)text rangeOfString:@"$0"];
        self.myNotificationName = [text stringByReplacingCharactersInRange:parentIdRange withString:parentID];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:self.myNotificationName object:nil];
    }
}

- (void)closeBang
{
    if (!self.parent) {
        return;
    }
    NSString *parentID = [self.parent uniqueID];
    NSString *closeBangNotificationName = [NSString stringWithFormat:@"%@-%@",parentID,kCloseBangNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:closeBangNotificationName object:nil];
    
    if (self.myNotificationName) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:self.myNotificationName object:nil];
    }
}

+ (NSString *)symbolAlias
{
    return @"re";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"r";
    NSString *text = arguments;
    
    if (![text hasPrefix:@"$0"]) {
        self.myNotificationName = nil;
    }else{
        self.myNotificationName = text;
    }
    
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
}

@end
