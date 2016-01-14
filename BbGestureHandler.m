//
//  BbGestureHandler.m
//  BbPatchViewTests
//
//  Created by Travis Henspeter on 1/7/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbGestureHandler.h"
#import "BbBlockMatrix+Helpers.h"

static void *XXContext  =   &XXContext;

@interface BbGestureHandler ()

@property (nonatomic,strong)            NSMutableArray                             *keyPaths;
@property (nonatomic,strong)            NSMutableArray                             *expressions;
@property (nonatomic,strong)            NSMutableArray                             *stateVector;
@property (nonatomic,strong)            NSMutableDictionary                        *currentState;
@property (nonatomic,strong)            BbBlockMatrix                              *blockMatrix;

@end

@implementation BbGestureHandler

- (instancetype)initWithHost:(id<BbGestureHandlerHost>)host
{
    self = [super init];
    if ( self ) {
        _host = host;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.blockMatrix = [[BbBlockMatrix alloc]initWithRows:BbGestureAction_Count columns:1];
    for (BbGestureAction action = BbGestureAction_AddObject; action < BbGestureAction_Count; action++) {
        [self.blockMatrix setValue:[BbBlockMatrix evaluatorTrue] forElementAtRow:action column:0];
    }
    
    self.keyPaths = [NSMutableArray arrayWithCapacity:BbGestureStateCondition_Count];
    self.stateVector = [NSMutableArray arrayWithCapacity:BbGestureStateCondition_Count];
    for (BbGestureStateCondition condition = BbGestureStateCondition_FirstViewType; condition < BbGestureStateCondition_Count; condition++) {
        self.keyPaths[condition] = @"";
        self.stateVector[condition] = @(0);
    }
}

- (void)setKeyPath:(NSString *)keyPath forStateCondition:(BbGestureStateCondition)stateCondition
{
    self.keyPaths[stateCondition] = keyPath;
}

- (void)setExpression:(NSString *)expression forAction:(BbGestureAction)action
{
    [self.blockMatrix setValue:[BbBlockMatrix evaluatorWithExpression:expression] forElementAtRow:action column:0];
}

- (void)beginObservingGestures
{
    for (NSString *aKeyPath in self.keyPaths) {
        [self beginObservingKeyPath:aKeyPath];
    }
    
    [self addObserver:self forKeyPath:@"stateVector" options:NSKeyValueObservingOptionNew context:XXContext];
    self.observingGestures = YES;
}

- (void)beginObservingKeyPath:(NSString *)keyPath
{
    id myHost = self.host;
    [myHost addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:XXContext];
}

- (void)endObservingGestures
{
    for ( NSString *aKeyPath in self.keyPaths ) {
        [self endObservingKeyPath:aKeyPath];
    }
    [self removeObserver:self forKeyPath:@"stateVector" context:XXContext];
    self.observingGestures = NO;
}

- (void)endObservingKeyPath:(NSString *)keyPath
{
    id myHost = self.host;
    [myHost removeObserver:self forKeyPath:keyPath context:XXContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == XXContext) {
        if ( [self.keyPaths containsObject:keyPath] ) {
            BbGestureStateCondition condition = [self.keyPaths indexOfObject:keyPath];
            NSString *expression = self.expressions[condition];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
