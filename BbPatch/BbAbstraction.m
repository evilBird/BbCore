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

- (id<BbPatchView>)open
{
    if (self.patch) {
        if (self.patch.view) {
            return self.patch.view;
        }else{
            return [self.patch loadView];
        }
    }
    return nil;
}

- (void)close
{
    if (self.patch) {
        [self.patch unloadView];
    }
}

+ (NSString *)emptyAbstractionDescription
{
    return [NSString stringWithFormat:@"#N BbView 0.0 0.0 BbAbstraction abstraction;\n"];
}

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments
{
    NSMutableArray *components = [(NSString *)arguments componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].mutableCopy;
    NSString *myArgs = components.firstObject;
    NSString *objArgs = [BbParseText objectArgumentsFromString:myArgs];
    self.displayText = [[objArgs stringByReplacingOccurrencesOfString:@"BbAbstraction" withString:@""]trimWhitespace];
    
    [components removeObjectAtIndex:0];
    NSString *theirArgs = [components componentsJoinedByString:@"\n"];
    NSDictionary *copied = [BbParseText parseCopiedText:theirArgs];
    [self setupWithChildDescriptions:copied];
}

- (void)setupWithChildDescriptions:(NSDictionary *)descriptions
{
    BbPatch *patch = [[BbPatch alloc]initWithArguments:nil];
    NSMutableArray *inletAttributes = [NSMutableArray array];
    NSMutableArray *outletAttributes = [NSMutableArray array];
    NSMutableArray *objectDescriptions = descriptions[kCopiedObjectDescriptionsKey];
    double sumOfPosX = 0.0;
    double sumOfPosY = 0.0;
    id dataSource = self.dataSource;
    for (BbObjectDescription *childDescription in objectDescriptions ) {
        
        NSArray *argArray = [NSArray arrayWithObjects:childDescription,dataSource, nil];
        BbObject *child = [NSInvocation doClassMethod:childDescription.objectClass selector:@"objectWithDescription:dataSource:" arguments:argArray];
        [patch addChildEntity:child];
        NSArray *pos = [child.viewArguments getArguments];
        sumOfPosX += ([(NSNumber *)pos.firstObject doubleValue]);
        sumOfPosY += ([(NSNumber *)pos.lastObject doubleValue]);
        if ([child isKindOfClass:[BbPatchInlet class]]) {
            [inletAttributes addObject:[BbAbstraction attributesForPatchPort:child]];
        }else if ([child isKindOfClass:[BbPatchOutlet class]]){
            [outletAttributes addObject:[BbAbstraction attributesForPatchPort:child]];
        }
    }
    //[self setupPortsForPatch:patch withInletAttributes:inletAttributes outletAttributes:outletAttributes];

    NSMutableArray *connectionsDescriptions = descriptions[kCopiedConnectionDescriptionsKey];
    for (BbConnectionDescription *connectionDescription in connectionsDescriptions ) {
        BbConnection *connection = [patch connectionWithDescription:connectionDescription];
        [connection.sender addChildEntity:connection];
    }
    
    [self setupPortsForPatch:patch withInletAttributes:inletAttributes outletAttributes:outletAttributes];
    
    self.patch = patch;
    self.patch.selectors = descriptions[kCopiedSelectorDescriptionsKey];
    
    double posX = sumOfPosX/(double)objectDescriptions.count;
    double posY = sumOfPosY/(double)objectDescriptions.count;
    self.viewArguments = [NSString stringWithFormat:@"%.3f %.3f",posX,posY];
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


- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender
{
    return (id<BbObjectViewEditingDelegate>)self;
}

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText
{
    return @"";
}

- (BOOL)canEdit
{
    return YES;
}

- (BOOL)canOpen
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)sender userEnteredText:(NSString *)text
{
    self.displayText = text;
}

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithText:(NSString *)text
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText
{
    self.displayText = [userText trimWhitespace];
}

- (NSSet *)childConnections
{
    NSSet *childConnections = [super childConnections];
    
    return childConnections;
}

- (NSString *)textDescription
{
    NSArray *viewArgs = [self.viewArguments getArguments];
    NSString *myDescription = [NSString stringWithFormat:@"#N BbView %@ %@ BbAbstraction %@;",viewArgs.firstObject,viewArgs.lastObject,self.displayText];
    self.patch.parent = self.parent;
    NSString *myPatchDescription = [self.patch textDescription];
    NSMutableArray *myComponents = [myPatchDescription componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].mutableCopy;
    [myComponents replaceObjectAtIndex:0 withObject:myDescription];
    NSString *myDesc = [myComponents componentsJoinedByString:@"\n"];//stringByAppendingString:@"\n"];
    
    return myDesc;
}
@end
