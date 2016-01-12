//
//  BbObject.m
//  BbObject
//
//  Created by Travis Henspeter on 1/8/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"

static void     *BbObjectContextXX      =       &BbObjectContextXX;

@interface BbObject ()


@end

@implementation BbObject

- (instancetype)initWithArguments:(NSString *)arguments
{
    self = [super init];
    if ( self ) {
        _objectArguments = arguments;
        [self commonInit];
        [self setupWithArguments:arguments];
    }
    
    return self;
}

- (void)commonInit
{
    self.uniqueID = [BbHelpers createUniqueIDString];
    self.objectClass = NSStringFromClass([self class]);
    self.myInlets = [NSMutableArray array];
    self.myOutlets = [NSMutableArray array];
    self.myChildren = [NSMutableArray array];
    self.myConnections = [NSMutableArray array];
    [self setupPorts];
}

- (void)setupPorts
{
    [self setupDefaultPorts];
}

- (void)setupWithArguments:(id)arguments {


}

+ (NSString *)myToken
{
    return @"#X";
}

- (NSString *)myViewClass
{
    return @"BbBoxView";
}

- (NSString *)textDescription
{
    NSMutableArray *myComponents = [NSMutableArray array];
    [myComponents addObject:[BbObject myToken]];
    
    NSString *view = nil;
    
    if ( nil != self.view ) {
        view = NSStringFromClass([self.view class]);
    }else{
        view = [self myViewClass];
    }
    
    [myComponents addObject:view];
    
    NSString *position = nil;
    
    if ( nil != self.view ) {
        position = [BbHelpers position2String:[self.view objectViewPosition:self]];
    }else{
        position = [BbHelpers position2String:nil];
    }
    
    [myComponents addObject:position];
    
    NSString *className = NSStringFromClass([self class]);
    [myComponents addObject:className];
    
    NSString *argsString = nil;
    
    if ( nil != self.objectArguments ) {
        argsString = self.objectArguments;
        [myComponents addObject:argsString];
    }
    
    NSString *endOfLine = @";\n";
    NSString *myDescription = [[myComponents componentsJoinedByString:@" "]stringByAppendingString:endOfLine];
    NSMutableString *mutableString = [NSMutableString stringWithString:myDescription];
    
    if ( self.myChildren ) {
        for (BbObject *aChild in self.myChildren ) {
            
            [mutableString appendFormat:@"\t%@",[aChild textDescription]];
        }
    }
    
    if ( nil != self.myConnections ) {
        for (BbConnection *aConnection in self.myConnections ) {
            
            [mutableString appendString:[aConnection textDescription]];
        }
    }
    
    return [NSString stringWithString:mutableString];
    
}


- (void)dealloc
{
    for ( BbConnection *aConnection in _myConnections.mutableCopy ) {
        [self removeChildObject:aConnection];
    }
    
    _myConnections = nil;
    
    for ( BbObject *aChildObject in _myChildren.mutableCopy ) {
        [self removeChildObject:aChildObject];
    }
    
    _myChildren = nil;
    
    for (BbInlet *anInlet in _myInlets.mutableCopy ) {
        [self removeChildObject:anInlet];
    }
    _myInlets = nil;
    
    for (BbOutlet *anOutlet in _myOutlets.mutableCopy ) {
        [self removeChildObject:anOutlet];
    }
    
    _myOutlets = nil;
    
    if ( nil != _view ) {
        [_view removeFromSuperView];
    }
    
    _view = nil;
    _calculateBlocks = nil;
    _calculateBlockTargets = nil;
}

@end
