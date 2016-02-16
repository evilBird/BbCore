//
//  BbRoute.m
//  Pods
//
//  Created by Travis Henspeter on 1/23/16.
//
//

#import "BbRoute.h"

@interface BbRoute ()

@property (nonatomic,strong)        NSMapTable      *routingTable;

@end

@implementation BbRoute

- (void)setupPorts {}

+ (NSString *)symbolAlias
{
    return @"r";
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    for (id<BbEntity> anInlet in self.inlets.mutableCopy) {
        [self removeChildEntity:anInlet];
    }
    for (id<BbEntity> anOutlet in self.outlets.mutableCopy) {
        [self removeChildEntity:anOutlet];
    }
    [self setupWithArguments:creationArguments];
    [self.view updateAppearance];
}


- (void)setupWithArguments:(id)arguments
{
    self.name = @"route";
    
    if ( nil == arguments ) {
        self.displayText = self.name;
        return;
    }else{
        self.displayText = [NSString stringWithFormat:@"%@ %@",self.name,arguments];
    }
    
    NSString *argString = arguments;
    NSArray *routeArgs = [argString getArguments];
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    self.routingTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
    
    for (id anArg in routeArgs ) {
        BbOutlet *anOutlet = [[BbOutlet alloc]init];
        [self addChildEntity:anOutlet];
        [self.routingTable setObject:anOutlet forKey:anArg];
    }
    
    BbOutlet *anOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:anOutlet];
    NSDictionary *routeTableDictionary = [self.routingTable dictionaryRepresentation];
    NSSet *routeKeysSet = [NSSet setWithArray:routeTableDictionary.allKeys];
    __weak BbRoute *weakself = self;
    
    [hotInlet setOutputBlock:^( id value ){
        if ( [value isKindOfClass:[NSArray class]] ) {
            NSArray *arr = value;
            id key = arr.firstObject;
            if ( ![routeKeysSet containsObject:key] ) {
                [weakself.outlets.lastObject setInputElement:value];
            }else{
                id output = nil;
                if ( arr.count == 1 ) {
                    output = [BbBang bang];
                }else{
                    NSRange rangeToKeep;
                    rangeToKeep.location = 1;
                    rangeToKeep.length = arr.count-1;
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:rangeToKeep];
                    output = [arr objectsAtIndexes:indexSet];
                }
                
                [[weakself.routingTable objectForKey:key]setInputElement:output];
            }
        }else if ( [value isKindOfClass:[NSDictionary class]]){
            NSDictionary *dict = value;
            NSMutableSet *dictKeysSet = [NSMutableSet setWithArray:dict.allKeys];
            [dictKeysSet intersectSet:routeKeysSet];
            if (!dictKeysSet.allObjects.count) {
                [weakself.outlets.lastObject setInputElement:value];
            }else{
                NSMutableDictionary *dictCopy = dict.mutableCopy;
                for (NSString *aKey in dictKeysSet) {
                    id objectForKey = [dictCopy valueForKey:aKey];
                    [[weakself.routingTable objectForKey:aKey]setInputElement:objectForKey];
                }
                [dictCopy removeObjectsForKeys:dictKeysSet.allObjects];
                
                if (dictCopy.allKeys.count) {
                    [[weakself.outlets lastObject]setInputElement:[NSDictionary dictionaryWithDictionary:dictCopy]];
                }
            }
        }
    }];
    
}



@end
