//
//  BbTextDescription.m
//  Pods
//
//  Created by Travis Henspeter on 1/10/16.
//
//

#import "BbTextDescription.h"

@implementation BbConnectionDescription

+ (NSArray *)connectionArgString2Array:(NSString *)argString
{
    NSArray *components = [argString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:components.count];
    for (NSString *aComponent in components) {
        [result addObject:@([aComponent integerValue])];
    }
    
    return result;
}

+ (BbConnectionDescription *)connectionDescriptionWithArgs:(NSString *)argString
{
    BbConnectionDescription *desc = [BbConnectionDescription new];
    NSEnumerator *argEnumerator = [BbConnectionDescription connectionArgString2Array:argString].objectEnumerator;
    desc.senderParentIndex = [(NSNumber *)[argEnumerator nextObject] unsignedIntegerValue];
    desc.senderPortIndex = [(NSNumber *)[argEnumerator nextObject] unsignedIntegerValue];
    desc.receiverParentIndex = [(NSNumber *)[argEnumerator nextObject] unsignedIntegerValue];
    desc.receiverPortIndex = [(NSNumber *)[argEnumerator nextObject] unsignedIntegerValue];
    return desc;
}

- (NSString *)humanReadableText
{
    return [NSString stringWithFormat:@"Connection: %@ %@ %@ %@",@(self.senderParentIndex),@(self.senderPortIndex),@(self.receiverParentIndex),@(self.receiverPortIndex)];
}

@end


@implementation BbObjectDescription

+ (BbObjectDescription *)objectDescriptionWithArgs:(NSString *)objectArgs viewArgs:(NSString *)viewArgs
{
    BbObjectDescription *desc = [BbObjectDescription new];
    NSMutableArray *objectArgArray = [objectArgs componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].mutableCopy;
    desc.objectClass = objectArgArray.firstObject;
    [objectArgArray removeObjectAtIndex:0];
    desc.objectArguments = [objectArgArray componentsJoinedByString:@" "];
    NSMutableArray *viewArgArray = [viewArgs componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].mutableCopy;
    desc.viewClass = viewArgArray.firstObject;
    [viewArgArray removeObjectAtIndex:0];
    desc.viewArguments = [viewArgArray componentsJoinedByString:@" "];
    return desc;
}

- (NSString *)humanReadableText
{
    return [NSString stringWithFormat:@"Object class: %@, args: %@, view class: %@, view args: %@",self.objectClass,self.objectArguments,self.viewClass,self.viewArguments];
}

@end


@implementation BbPatchDescription

+ (BbPatchDescription *)patchDescriptionWithArgs:(NSString *)objectArgs viewArgs:(NSString *)viewArgs
{
    BbPatchDescription *desc = [BbPatchDescription new];
    NSMutableArray *objectArgArray = [objectArgs componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].mutableCopy;
    desc.objectClass = objectArgArray.firstObject;
    [objectArgArray removeObjectAtIndex:0];
    desc.objectArguments = [objectArgArray componentsJoinedByString:@" "];
    NSMutableArray *viewArgArray = [viewArgs componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].mutableCopy;
    desc.viewClass = viewArgArray.firstObject;
    [viewArgArray removeObjectAtIndex:0];
    desc.viewArguments = [viewArgArray componentsJoinedByString:@" "];
    return desc;
}

- (NSString *)depthString
{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for (NSUInteger i = 0; i < self.depth ; i ++ ) {
        [result appendString:@"\t"];
    }
    
    return result;
}

- (NSString *)childDepthString
{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for (NSUInteger i = 0; i <= self.depth ; i ++ ) {
        [result appendString:@"\t"];
    }
    
    return result;
}

- (NSString *)humanReadableText
{
    NSString *objectText = [super humanReadableText];
    NSString *childDepthString = [self childDepthString];
    NSString *myDepthString = [self depthString];
    NSMutableString *result = [NSMutableString stringWithString:objectText];
    [result appendString:@"\n"];
    if ( nil != self.childObjectDescriptions ) {
        for (BbObjectDescription *childDescription in self.childObjectDescriptions ) {
                [result appendFormat:@"%@%@\n",childDepthString,[childDescription humanReadableText]];
        }
    }
    
    if ( nil != self.childConnectionDescriptions ) {
        for (BbConnectionDescription *connectionDescription in self.childConnectionDescriptions ) {
            [result appendFormat:@"%@%@\n",childDepthString,[connectionDescription humanReadableText]];
        }
    }
    
    if ( nil != self.selectorDescriptions ) {
        for (NSString *selectorDescription in self.selectorDescriptions) {
            [result appendFormat:@"%@Selector: %@",myDepthString,selectorDescription];
        }
    }
    
    return result;
}

- (void)addChildPatchDescription:(BbPatchDescription *)patchDescription
{
    if ( nil == self.childObjectDescriptions ) {
        self.childObjectDescriptions = [NSMutableArray array];
    }
    
    [self.childObjectDescriptions addObject:patchDescription];
}

- (void)addChildObjectDescriptionWithArgs:(NSString *)objectArgs viewArgs:(NSString *)viewArgs
{
    if ( nil == self.childObjectDescriptions ) {
        self.childObjectDescriptions = [NSMutableArray array];
    }
    
    [self.childObjectDescriptions addObject:[BbObjectDescription objectDescriptionWithArgs:objectArgs viewArgs:viewArgs]];
}

- (void)addChildConnectionDescriptionWithArgs:(NSString *)connectionArgs
{
    if ( nil == self.childConnectionDescriptions ) {
        self.childConnectionDescriptions = [NSMutableArray array];
    }
    
    [self.childConnectionDescriptions addObject:[BbConnectionDescription connectionDescriptionWithArgs:connectionArgs]];
}

- (void)addSelectorDescription:(NSString *)selectorArgs
{
    if ( nil == self.selectorDescriptions ) {
        self.selectorDescriptions = [NSMutableArray array];
    }
    
    [self.selectorDescriptions addObject:selectorArgs];
}

@end