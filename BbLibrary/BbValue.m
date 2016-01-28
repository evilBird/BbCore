//
//  BbValue.m
//  Pods
//
//  Created by Travis Henspeter on 1/26/16.
//
//

#import "BbValue.h"


@implementation BbValue

- (void)setupPorts
{
    [super setupPorts];
    
    BbInlet *rightInlet = self.inlets[1];
    rightInlet.hot = YES;
    __block id aValue = nil;
    
    [rightInlet setOutputBlock:^( id value ){
        aValue = value;
    }];
    
    BbInlet *leftInlet = self.inlets[0];
    __block BbOutlet *mainOutlet = self.outlets[0];
    [leftInlet setOutputBlock:^(id value){
        if ( [value isKindOfClass:[BbBang class]] ) {
            mainOutlet.inputElement = aValue;
        }
    }];
}

+ (NSString *)symbolAlias
{
    return @"val";
}

- (void)setupWithArguments:(id)arguments
{
    if ( nil == arguments ) {
        self.displayText = @"value";
    }
}

@end
