//
//  BbPatchObject.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbPatchObject.h"
#import "BbPatch.h"
#import "BbTextDescription.h"
#import "BbParseText.h"
#import "BbRuntime.h"
#import "BbSymbolTable.h"


static NSString *kPortAttributeKeyPort      =       @"port";
static NSString *kPortAttributeKeyXPosition =       @"x";

@interface BbPatchObject ()

@property (nonatomic,strong)        BbPatch                         *patch;
@property (nonatomic, strong)       BbPatchDescription              *patchDescription;
@property (nonatomic, strong)       NSMutableSet                    *myConnections;
@property (nonatomic,strong)        NSArray                         *childArguments;

@end

@implementation BbPatchObject

- (void)setupPorts {}

- (NSString *)patchNameFromText:(NSString *)text
{
    NSArray *allPatchNames = [[self.dataSource allPatchNames]valueForKey:@"name"];
    NSSet *patchNameSet = [NSSet setWithArray:allPatchNames];
    NSMutableArray *components = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].mutableCopy;
    __block NSMutableString *patchName = [[NSMutableString alloc]initWithString:components.firstObject];
    [components removeObjectAtIndex:0];
    [components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *proposedPatchName = [[NSString stringWithString:patchName]stringByAppendingFormat:@" %@",obj];
        if ([patchNameSet containsObject:proposedPatchName]) {
            [patchName appendFormat:@" %@",obj];
        }else{
            *stop = YES;
        }
    }];
    
    return [NSString stringWithString:patchName];
}

- (void)setupWithArguments:(id)arguments
{
    if ( nil == arguments ) {
        return;
    }
    self.displayText = arguments;
    NSString *patchName = [self patchNameFromText:arguments];
    NSString *patchArgs = [arguments stringByReplacingCharactersInRange:[arguments rangeOfString:patchName] withString:@""];
    self.childArguments = [patchArgs getArguments];
    NSString *text = [self.dataSource object:self textForPatchName:patchName];
    [self setupWithText:text patchArgs:[patchArgs getArguments]];
}

- (void)creationArgumentsDidChange:(NSString *)creationArguments
{
    [super creationArgumentsDidChange:creationArguments];
    [self setupWithArguments:creationArguments];
}

- (void)setupWithText:(NSString *)text patchArgs:(NSArray *)patchArgs
{
    if ( nil == text) {
        return;
    }
    
    BbPatchDescription *patchDescription = [BbParseText parseText:text];
    BbPatch *patch = [[BbPatch alloc]initWithArguments:nil];
    patch.childArguments = patchArgs;
    patch.selectors = patchDescription.selectorDescriptions;
    NSMutableArray *inletAttributes = [NSMutableArray array];
    NSMutableArray *outletAttributes = [NSMutableArray array];
    id dataSource = self.dataSource;
    for (BbObjectDescription *childDescription in patchDescription.childObjectDescriptions) {
        NSString *descArgs = childDescription.objectArguments;
        NSString *subsArgs = [patch makeSubstitutionsInChildArgs:descArgs];
        childDescription.objectArguments = subsArgs;
        NSArray *argArray = [NSArray arrayWithObjects:childDescription,dataSource, nil];
        BbObject *child = [NSInvocation doClassMethod:childDescription.objectClass selector:@"objectWithDescription:dataSource:" arguments:argArray];
        [patch addChildEntity:child];
        if ([child isKindOfClass:[BbPatchInlet class]]) {
            [inletAttributes addObject:[BbPatchObject attributesForPatchPort:child]];
        }else if ([child isKindOfClass:[BbPatchOutlet class]]){
            [outletAttributes addObject:[BbPatchObject attributesForPatchPort:child]];
        }
    }
    //[self setupPortsForPatch:patch withInletAttributes:inletAttributes outletAttributes:outletAttributes];

    for (BbConnectionDescription *connectionDescription in patchDescription.childConnectionDescriptions) {
        BbConnection *connection = [patch connectionWithDescription:connectionDescription];
        [connection.sender addChildEntity:connection];
    }
    
    [self setupPortsForPatch:patch withInletAttributes:inletAttributes outletAttributes:outletAttributes];
    
    self.patchDescription = patchDescription;
    self.patch = patch;
    if (self.patch.selectors) {
        [self.patch doSelectors];
    }
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
    self.myConnections = [NSMutableSet set];
    for ( NSDictionary *inletAttrs in sortedInlets ) {
        __block BbPatchInlet *patchInlet = inletAttrs[kPortAttributeKeyPort];
        BbInlet *myInlet = [[BbInlet alloc]init];
        myInlet.hot = YES;
        [self addChildEntity:myInlet];
        [myInlet setOutputBlock:^( id value ){
            [patchInlet.inlets.firstObject setInputElement:value];
        }];
    }
    
    NSArray *sortedOutlets = [outletAttributes sortedArrayUsingDescriptors:@[sortByXPositionDescriptor]];
    for ( NSDictionary *outletAttrs in sortedOutlets ) {
        __block BbOutlet *myOutlet = [[BbOutlet alloc]init];
        [self addChildEntity:myOutlet];
        BbPatchOutlet *patchOutlet = outletAttrs[kPortAttributeKeyPort];
        __block id outputValue;
        [patchOutlet.outlets.firstObject setOutputBlock:^(id value){
            outputValue = value;
            myOutlet.inputElement = outputValue;
        }];
    }
}

- (void)cleanup
{
    
}

+ (NSString *)symbolAlias
{
    return @"patch object";
}

+ (NSString *)viewClass
{
    return @"BbView";
}

+ (BOOL)test
{
    NSString *arguments = @"#N BbPatchView 1.0 1.0 0.0 0.0 1.0 BbPatch TEST;\n\t#X BbPatchInletView 0.0 -0.2 BbPatchInlet;\n\t#X BbPatchOutletView 0.0 0.2 BbPatchOutlet;\n\t#X BbConnection 0 0 1 0;\n#S loadView;\n";
    BbPatchObject *patchObject = [[BbPatchObject alloc]initWithArguments:arguments];
    BOOL inletsOk = patchObject.inlets.count == 1;
    BOOL outletsOk = patchObject.outlets.count == 1;
    NSString *passthruMessage = @"Message";
    [patchObject.inlets[0] setInputElement:passthruMessage];
    id output = [patchObject.outlets[0] outputElement];
    BOOL passThruOK = ( nil != output && [output isEqualToString:passthruMessage] );
    return ( inletsOk && outletsOk && passThruOK );
}

@end
