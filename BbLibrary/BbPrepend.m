//
//  BbPrepend.m
//  Pods
//
//  Created by Travis Henspeter on 1/29/16.
//
//

#import "BbPrepend.h"
@interface BbPrepend ()

@property (nonatomic,strong)    id  myColdValue;

@end


@implementation BbPrepend

- (void)setupPorts
{
    [super setupPorts];
    BbInlet *hotInlet = self.inlets.firstObject;
    BbInlet *coldInlet = self.inlets.lastObject;
    coldInlet.hot = YES;
    __block BbOutlet *mainOutlet = self.outlets.lastObject;
    __block NSMutableArray *outputValue = [NSMutableArray array];
    __weak BbPrepend *weakself = self;
    
    [coldInlet setOutputBlock:^(id value){
        if ( [value isKindOfClass:[BbBang class]] ) {
            weakself.myColdValue = nil;
        }else{
            weakself.myColdValue = value;
        }
    }];
    
    [hotInlet setOutputBlock:^(id value){
        //outputValue = nil;
        if (!value && !weakself.myColdValue) return;
        if (value && !weakself.myColdValue) {
            outputValue = [NSMutableArray arrayWithObject:value];
        }else if (value && weakself.myColdValue){
            if ([value isKindOfClass:[NSArray class]] && ![weakself.myColdValue isKindOfClass:[NSArray class]]) {
                outputValue = [NSMutableArray arrayWithObject:weakself.myColdValue];
                [outputValue addObjectsFromArray:value];
            }else if (![value isKindOfClass:[NSArray class]] && [weakself.myColdValue isKindOfClass:[NSArray class]]){
                outputValue = [NSMutableArray arrayWithArray:weakself.myColdValue];
                [outputValue addObject:value];
            }else if (![value isKindOfClass:[NSArray class]] && ![weakself.myColdValue isKindOfClass:[NSArray class]]){
                outputValue = [NSMutableArray arrayWithObject:weakself.myColdValue];
                [outputValue addObject:value];
            }else if ([value isKindOfClass:[NSArray class]] && [weakself.myColdValue isKindOfClass:[NSArray class]]){
                outputValue = [NSMutableArray arrayWithArray:weakself.myColdValue];
                [outputValue addObjectsFromArray:value];
            }
        }
        
        if (outputValue) {
            [mainOutlet setInputElement:outputValue];
        }
    }];
    
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"prepend";
    
    if ( arguments ) {
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
        if (arguments && [arguments isKindOfClass:[NSString class]]) {
            if ([arguments trimWhitespace].length == 0) {
                self.myColdValue = nil;
            }else{
                self.myColdValue = [[arguments trimWhitespace]getArguments];
            }
        }
    }else{
        self.displayText = [NSString stringWithFormat:@"%@",self.name];
    }
 

    
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    NSArray *args = [creationArguments getArguments];
    [self.inlets[1] setInputElement:args.lastObject];
}

+ (NSString *)symbolAlias
{
    return @"pre";
}



@end
