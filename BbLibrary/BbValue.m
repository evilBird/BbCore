//
//  BbValue.m
//  Pods
//
//  Created by Travis Henspeter on 1/26/16.
//
//

#import "BbValue.h"

@interface BbValue ()

@property (nonatomic,strong)    id  myValue;

@end

@implementation BbValue

- (void)setupPorts
{
    [super setupPorts];
    
    BbInlet *rightInlet = self.inlets[1];
    rightInlet.hot = YES;
    __weak BbValue *weakself = self;
    [rightInlet setOutputBlock:^( id value ){
        weakself.myValue = value;
    }];
    
    BbInlet *leftInlet = self.inlets[0];
    __block BbOutlet *mainOutlet = self.outlets[0];
    [leftInlet setOutputBlock:^(id value){
        if ( [value isKindOfClass:[BbBang class]] ) {
            mainOutlet.inputElement = weakself.myValue;
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
    return @"val";
}

- (void)setupWithArguments:(id)arguments
{
    if ( nil == arguments ) {
        self.displayText = @"value";
    }else{
        self.displayText = [NSString stringWithFormat:@"value %@",arguments];
        NSArray *args = [arguments getArguments];
        if (args.count == 1) {
            self.myValue = args.firstObject;
        }else{
            self.myValue = args;
        }
    }
}

@end
