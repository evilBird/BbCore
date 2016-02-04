//
//  BbCanvas.m
//  Pods
//
//  Created by Travis Henspeter on 1/26/16.
//
//

#import "BbCanvas.h"

@interface BbCanvas ()

@end

@implementation BbCanvas

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    __block BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
    
    __weak BbCanvas *weakself = self;
    [hotInlet setOutputBlock:^(id value){
        id theCanvas = [weakself.dataSource canvasForObject:weakself];
        NSString *selector = [BbHelpers getSelectorFromArray:value];
        NSArray *args = [BbHelpers getArgumentsFromArray:value];
        id output = [NSInvocation doInstanceMethod:theCanvas selector:selector arguments:args];
        if ( nil != output ) {
            mainOutlet.inputElement = [NSArray arrayWithObjects:selector,output,nil];
        }
    }];
}

+ (NSString *)symbolAlias
{
    return @"canvas";
}

- (void)setupWithArguments:(id)arguments
{
    self.displayText = @"canvas";
}

- (void)cleanup
{
    UIView *canvas = [self.dataSource canvasForObject:self];
    for (UIView *aSubview in canvas.subviews) {
        [aSubview removeFromSuperview];
    }
}

@end
