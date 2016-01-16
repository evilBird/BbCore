//
//  BbDynamicProtocolAdopter.h
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BbRuntimeProtocolAdopterProxy <NSObject>

- (id)protocolAdopter:(id)sender forwardsSelector:(NSString *)selectorName withArguments:(NSArray *)arguments expectsReturnType:(NSString *)returnType;

@end

@interface BbRuntimeProtocolAdopter : NSObject

@property (nonatomic,weak)          id<BbRuntimeProtocolAdopterProxy>           proxyObject;

- (instancetype)initWithClientClass:(NSString *)className clientProperty:(NSString *)propertyName proxy:(id<BbRuntimeProtocolAdopterProxy>)proxyObject;

@end
