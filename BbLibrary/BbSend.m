//
//  BbSend.m
//  Pods
//
//  Created by Travis Henspeter on 1/30/16.
//
//

#import "BbSend.h"

@interface BbSend ()

@property (nonatomic,strong)                    NSString        *myNotificationName;

@end

@implementation BbSend

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    BbInlet *coldInlet = [[BbInlet alloc]init];
    coldInlet.hot = YES;
    [self addChildEntity:coldInlet];
    
    __weak BbSend *weakself = self;
    [coldInlet setOutputBlock:^(id value){
        if (value) {
            if ([value isKindOfClass:[NSString class]]) {
                weakself.myNotificationName = value;
            }else if ([value isKindOfClass:[NSArray class]]){
                NSArray *vals = value;
                if (vals.count && [vals.firstObject isKindOfClass:[NSString class]]) {
                    weakself.myNotificationName = vals.firstObject;
                }
            }
        }
    }];
    
    [hotInlet setOutputBlock:^(id value){
        if (value) {
            [weakself sendValue:value];
        }
    }];
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

+ (NSString *)symbolAlias
{
    return @"s";
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"s";
    self.myNotificationName = arguments;
    self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
}

- (void)sendValue:(id)value
{
    NSString *parentIdProxy = @"$0";
    NSString *notificationName = self.myNotificationName;
    NSRange proxyRange = [notificationName rangeOfString:parentIdProxy];
    if ( [notificationName hasPrefix:parentIdProxy] ) {
        NSString *textCopy = notificationName.copy;
        NSString *parentID = [self.parent uniqueID];
        notificationName = [textCopy stringByReplacingCharactersInRange:proxyRange withString:parentID];
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:notificationName object:value];
}

@end
