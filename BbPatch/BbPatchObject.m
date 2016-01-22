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


static NSString *kPortAttributeKeyPort      =       @"port";
static NSString *kPortAttributeKeyXPosition =       @"x";

@interface BbPatchObject ()

@property (nonatomic,strong)        BbPatch                         *patch;
@property (nonatomic, strong)       BbPatchDescription              *patchDescription;

@end

@implementation BbPatchObject

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments
{
    if ( nil == arguments ) {
        return;
    }
    
    BbPatchDescription *patchDescription = [BbParseText parseText:arguments];
    BbPatch *patch = [[BbPatch alloc]initWithArguments:nil];
    NSMutableArray *inletAttributes = [NSMutableArray array];
    NSMutableArray *outletAttributes = [NSMutableArray array];
    
    for (BbObjectDescription *childDescription in patchDescription.childObjectDescriptions) {
        BbObject *child = [NSInvocation doClassMethod:childDescription.objectClass selector:@"objectWithDescription:" arguments:childDescription];
        [patch addChildEntity:child];
        if ([child isKindOfClass:[BbPatchInlet class]]) {
            [inletAttributes addObject:[BbPatchObject attributesForPatchPort:child]];
        }else if ([child isKindOfClass:[BbPatchOutlet class]]){
            [outletAttributes addObject:[BbPatchObject attributesForPatchPort:child]];
        }
    }
    
    for (BbConnectionDescription *connectionDescription in patchDescription.childConnectionDescriptions) {
        BbConnection *connection = [patch connectionWithDescription:connectionDescription];
        [patch addChildEntity:connection];
    }
    
    [self setupPortsForPatch:patch withInletAttributes:inletAttributes outletAttributes:outletAttributes];
    self.patchDescription = patchDescription;
    self.patch = patch;
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

+ (NSString *)symbolAlias
{
    return @"patch object";
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
