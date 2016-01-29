//
//  BbAbstraction.m
//  Pods
//
//  Created by Travis Henspeter on 1/27/16.
//
//

#import "BbAbstraction.h"
#import "BbPatchObject.h"
#import "BbPatch.h"
#import "BbParseText.h"
#import "BbTextDescription.h"

static NSString *kPortAttributeKeyPort      =       @"port";
static NSString *kPortAttributeKeyXPosition =       @"x";

@interface BbAbstraction ()

@property (nonatomic,strong)    BbPatch                 *patch;

@end

@implementation BbAbstraction

+ (NSString *)viewClass
{
    return @"BbView";
}

+ (NSString *)symbolAlias
{
    return @"abstraction";
}

+ (NSString *)textDescriptionToken
{
    return @"#N";
}

+ (NSString *)emptyAbstractionDescription
{
    return [NSString stringWithFormat:@"#N BbView 0.0 0.0 BbAbstraction;\n"];
}

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments
{
    NSMutableArray *components = [(NSString *)arguments componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].mutableCopy;
    NSString *myArgs = components.firstObject;
    self.displayText = myArgs;
    [components removeObjectAtIndex:0];
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:components.count];
    for (NSString *aComponent in components ) {
        [temp addObject:[aComponent trimWhitespace]];
    }
    NSString *remainingArgs = [temp componentsJoinedByString:@"\n"];
    NSDictionary *copied = [BbParseText parseCopiedText:remainingArgs];
    [self setupWithChildDescriptions:copied];
}

- (void)setupWithChildDescriptions:(NSDictionary *)descriptions
{
    BbPatch *patch = [[BbPatch alloc]initWithArguments:nil];
    NSMutableArray *inletAttributes = [NSMutableArray array];
    NSMutableArray *outletAttributes = [NSMutableArray array];
    NSMutableArray *objectDescriptions = descriptions[kCopiedObjectDescriptionsKey];
    for (BbObjectDescription *childDescription in objectDescriptions ) {
        BbObject *child = [NSInvocation doClassMethod:childDescription.objectClass selector:@"objectWithDescription:" arguments:childDescription];
        [patch addChildEntity:child];
        if ([child isKindOfClass:[BbPatchInlet class]]) {
            [inletAttributes addObject:[BbAbstraction attributesForPatchPort:child]];
        }else if ([child isKindOfClass:[BbPatchOutlet class]]){
            [outletAttributes addObject:[BbAbstraction attributesForPatchPort:child]];
        }
    }
    
    NSMutableArray *connectionsDescriptions = descriptions[kCopiedConnectionDescriptionsKey];
    for (BbConnectionDescription *connectionDescription in connectionsDescriptions ) {
        BbConnection *connection = [patch connectionWithDescription:connectionDescription];
        [connection.sender addChildEntity:connection];
    }
    
    [self setupPortsForPatch:patch withInletAttributes:inletAttributes outletAttributes:outletAttributes];
    self.patch = patch;
    self.patch.selectors = descriptions[kCopiedSelectorDescriptionsKey];
    
}

+ (NSDictionary *)attributesForPatchPort:(BbObject *)port
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSValue *position = [BbHelpers positionFromViewArgs:port.viewArguments];
    attributes[kPortAttributeKeyPort] = port;
    attributes[kPortAttributeKeyXPosition] = @([position CGPointValue].x);
    return attributes;
}

- (void)setupPortsForPatch:(BbPatch *)patch withInletAttributes:(NSArray *)inletAttributes outletAttributes:(NSArray *)outletAttributes
{
    NSSortDescriptor *sortByXPositionDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"x" ascending:YES];
    NSArray *sortedInlets = [inletAttributes sortedArrayUsingDescriptors:@[sortByXPositionDescriptor]];
    for ( NSDictionary *inletAttrs in sortedInlets ) {
        __block BbPatchInlet *patchInlet = inletAttrs[kPortAttributeKeyPort];
        BbInlet *myInlet = [[BbInlet alloc]init];
        myInlet.hot = YES;
        [self addChildEntity:myInlet];
        [myInlet setOutputBlock:^(id value){
            [patchInlet.inlets.firstObject setInputElement:value];
        }];
    }
    
    NSArray *sortedOutlets = [outletAttributes sortedArrayUsingDescriptors:@[sortByXPositionDescriptor]];
    for ( NSDictionary *outletAttrs in sortedOutlets ) {
        __block BbOutlet *myOutlet = [[BbOutlet alloc]init];
        [self addChildEntity:myOutlet];
        BbPatchOutlet *patchOutlet = outletAttrs[kPortAttributeKeyPort];
        [patchOutlet.outlets.firstObject setOutputBlock:^(id value){
            myOutlet.inputElement = value;
        }];
    }
}


@end
