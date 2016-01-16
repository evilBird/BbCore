//
//  BbDataSource.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound LLC. All rights reserved.
//

#import "BbDataSource.h"
#import "BbRuntime.h"

@interface BbDataSource () <BbRuntimeProtocolAdopterProxy>

@property (nonatomic,strong)        BbRuntimeProtocolAdopter            *dynamicDataSource;
@property (nonatomic,strong)        NSString                            *clientClass;
@property (nonatomic,strong)        NSMutableDictionary                 *returnValues;

@end

@implementation BbDataSource

- (void)setupWithArguments:(id)arguments
{
    NSString *clientClass = nil;
    
    if ( nil != arguments ) {
        if ( [arguments isKindOfClass:[NSArray class]] ) {
            NSArray *arr = arguments;
            clientClass = arr.firstObject;
        }else if ( [arguments isKindOfClass:[NSString class] ]){
            clientClass = arguments;
        }
    }
    
    if ( nil == clientClass ) {
        self.name = @"DataSource";
    }else{
        self.name = @"DataSource";
        self.clientClass = clientClass;
        [self createDynamicDelegate];
    }
    
    self.selectorOutlet = [[BbOutlet alloc]init];
    self.selectorOutlet.name = @"selectors";
    [self addPort:self.selectorOutlet];
    
    self.returnValues = [NSMutableDictionary dictionary];
    
}

- (BbInlet *)makeRightInlet
{
    BbInlet *rightInlet = [[BbInlet alloc]initHot];
    rightInlet.name = @"return values";
    rightInlet.delegate = self;
    return rightInlet;
}

- (void)portReceivedBang:(id)sender
{
    if ( sender == self.hotInlet ) {
        [self.mainOutlet output:self.dynamicDataSource];
    }
}

- (void)hotInlet:(BbInlet *)inlet receivedValue:(id)value
{
    if ( inlet == self.hotInlet ) {
        id hot = self.hotInlet.value;
        if ( [hot isKindOfClass:[NSNumber class] ]) {
            NSNumber *val = hot;
            NSUInteger value = val.unsignedIntegerValue;
            
            if ( value ) {
                [self createDynamicDelegate];
                [self.mainOutlet output:self.dynamicDataSource];
            }else{
                self.dynamicDataSource = nil;
            }
        }
        return;
    }
    
    if ( [inlet.name isEqualToString:@"return values"] ) {
        if ( nil == value ) {
            return;
        }
        
        if ( [value isKindOfClass:[NSArray class]] ) {
            NSArray *val = value;
            NSMutableArray *valCopy = val.mutableCopy;
            id firstVal = valCopy.firstObject;
            [valCopy removeObjectAtIndex:0];
            if ( [firstVal isKindOfClass:[NSString class]] ) {
                NSString *selectorName = firstVal;
                if ( valCopy.count ) {
                    self.returnValues[selectorName] = [NSArray arrayWithArray:valCopy];
                }
            }
        }
    }
}

- (void)calculateOutput {}

- (void)createDynamicDelegate
{
    self.dynamicDataSource = nil;
    [self.returnValues removeAllObjects];
    self.returnValues = nil;
    self.returnValues = [NSMutableDictionary dictionary];
    self.dynamicDataSource = [[BbRuntimeProtocolAdopter alloc]initWithClientClass:self.clientClass clientProperty:@"dataSource" proxy:self];
}

#pragma mark - BbRuntimeProtocolAdopterProxy

- (id)protocolAdopter:(id)sender forwardsSelector:(NSString *)selectorName withArguments:(NSArray *)arguments expectsReturnType:(NSString *)returnType
{
    if ( nil == selectorName ) {
        return nil;
    }
    
    NSMutableArray *toSend = [NSMutableArray array];
    [toSend addObject:selectorName];
    
    if ( nil != arguments ) {
        [toSend addObjectsFromArray:arguments];
    }
    
    [self.selectorOutlet output:[NSArray arrayWithArray:toSend]];
    return [self getReturnValueForSelector:selectorName];
}

- (id)getReturnValueForSelector:(NSString *)selectorName
{
    if ( ![self.returnValues.allKeys containsObject:selectorName] ) {
        return nil;
    }
    
    return [self.returnValues valueForKey:selectorName];
}

@end
