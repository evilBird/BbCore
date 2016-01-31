//
//  BbPrepend.m
//  Pods
//
//  Created by Travis Henspeter on 1/29/16.
//
//

#import "BbPrepend.h"
@interface BbPrepend ()

@end


@implementation BbPrepend

- (void)setupWithArguments:(id)arguments
{
    self.name = @"prepend";
    if ( arguments ) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
    }else{
        self.displayText = [NSString stringWithFormat:@"%@",self.name];
    }
 
    BbInlet *hotInlet = self.inlets.firstObject;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    __block BbOutlet *mainOutlet = self.outlets.lastObject;
    __block id coldValue = arguments;
    if (arguments && [arguments isKindOfClass:[NSString class]]) {
        if ([arguments trimWhitespace].length == 0) {
            coldValue = nil;
        }
    }
    __block NSMutableArray *outputValue = [NSMutableArray array];
    [coldInlet setOutputBlock:^(id value){
        if ( [value isKindOfClass:[BbBang class]] ) {
            coldValue = nil;
        }else{
            coldValue = value;
        }
    }];
    
    [hotInlet setOutputBlock:^(id value){
        //outputValue = nil;
        if (!value && !coldValue) return;
        if (value && !coldValue) {
            outputValue = [NSMutableArray arrayWithObject:value];
        }else if (value && coldValue){
            if ([value isKindOfClass:[NSArray class]] && ![coldValue isKindOfClass:[NSArray class]]) {
                outputValue = [NSMutableArray arrayWithObject:coldValue];
                [outputValue addObjectsFromArray:value];
            }else if (![value isKindOfClass:[NSArray class]] && [coldValue isKindOfClass:[NSArray class]]){
                outputValue = [NSMutableArray arrayWithArray:coldValue];
                [outputValue addObject:value];
            }else if (![value isKindOfClass:[NSArray class]] && ![coldValue isKindOfClass:[NSArray class]]){
                outputValue = [NSMutableArray arrayWithObject:coldValue];
                [outputValue addObject:value];
            }else if ([value isKindOfClass:[NSArray class]] && [coldValue isKindOfClass:[NSArray class]]){
                outputValue = [NSMutableArray arrayWithArray:coldValue];
                [outputValue addObjectsFromArray:outputValue];
            }
        }
        
        if (outputValue) {
            [mainOutlet setInputElement:outputValue];
        }
    }];
    
}

+ (NSString *)symbolAlias
{
    return @"pre";
}



@end
