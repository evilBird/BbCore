//
//  BbPointer.m
//  Pods
//
//  Created by Travis Henspeter on 2/26/16.
//
//

#import "BbPointer.h"

@interface BbPointer () <BbRuntimeProtocolAdopterProxy>

@property (nonatomic,strong)        id          myInstance;
@property (nonatomic,strong)        id          myInstanceDelegate;

@end

@implementation BbPointer

- (void)setMyInstance:(id)myInstance
{
    if (myInstance == _myInstance) {
        
        return;
        
    }else{
        
        _myInstance = nil;
        _myInstanceDelegate = nil;
    }
    
    _myInstance = myInstance;
    
    if ([myInstance respondsToSelector:@selector(setDelegate:)]) {
        [self setDelegateForInstance:_myInstance];
    }
}

- (void)setDelegateForInstance:(id)myInstance
{
    _myInstanceDelegate = [[BbRuntimeProtocolAdopter alloc]initWithProxy:self];
    objc_property_t prop = class_getProperty([myInstance class], "delegate");
}

- (id)protocolAdopter:(id)sender forwardsSelector:(NSString *)selectorName withArguments:(NSArray *)arguments expectsReturnType:(NSString *)returnType
{
    
}


@end
