//
//  BbFormattedString.m
//  Pods
//
//  Created by Travis Henspeter on 2/12/16.
//
//

#import "BbFormattedString.h"
#import "BbHelpers.h"

@interface BbFormattedString ()

@property (nonatomic,strong)    NSString    *myFormatString;

@end

@implementation BbFormattedString

+ (NSString *)symbolAlias
{
    return @"fs";
}

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *hotInlet = self.inlets.firstObject;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    __block BbOutlet *mainOutlet = self.outlets.firstObject;
    __weak BbFormattedString *weakself = self;
    [coldInlet setOutputBlock:^(id value){
        NSString *newFormatString = nil;
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *val = value;
            if ([val.firstObject isKindOfClass:[NSString class]]) {
                newFormatString = val.firstObject;
            }
        }else if ([value isKindOfClass:[NSString class]]){
            newFormatString = value;
        }
        
        if (newFormatString) {
            weakself.myFormatString = newFormatString;
        }
    }];
    
    __block NSString *myResult;
    
    [hotInlet setOutputBlock:^(id value){
        
        if (![value isKindOfClass:[NSArray class]] || !weakself.myFormatString) {
            return;
        }
        
        myResult = [BbHelpers stringWithFormat:weakself.myFormatString arguments:value];
        if (myResult) {
            [mainOutlet setInputElement:myResult];
        }
    }];
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"formatted string";

    if (!arguments){
        self.displayText = self.name;
    }else{
        self.myFormatString = arguments;
        self.displayText = [NSString stringWithFormat:@"%@, ...",self.myFormatString];
    }
    
}

@end
