//
//  BbParseText.m
//  Pods
//
//  Created by Travis Henspeter on 1/10/16.
//
//

#import "BbParseText.h"
#import "BbRuntime.h"
#import "BbPatch.h"
#import "BbCoreProtocols.h"

static NSString     *kParentToken       =       @"N";
static NSString     *kChildToken        =       @"X";
static NSString     *kSelectorToken     =       @"S";

@interface BbParseText ()

@property (nonatomic,strong)        NSString        *myText;
@property (nonatomic,strong)        NSString        *mySeparator;
@property (nonatomic,strong)        NSString        *myDepthToken;
@property (nonatomic,strong)        NSArray         *myComponents;
@property (nonatomic,strong)        NSEnumerator    *myComponentEnumerator;
@property (nonatomic)               NSUInteger      myDepth;
@property (nonatomic)               NSUInteger      myTextLocation;
@end

@implementation BbParseText


+ (NSUInteger)countOccurencesOfSubstring:(NSString *)substring beforeSubstring:(NSString *)endString inString:(NSString *)string
{
    if ( string.length == 0 || substring.length == 0 ) {
        return 0;
    }
    
    NSRange endRange = [string rangeOfString:endString options:NSLiteralSearch];
    if ( endRange.location == 0 ) {
        return 0;
    }
    
    NSRange range = [string rangeOfString:substring options:NSLiteralSearch];
    if ( range.length == 0 ) {
        return 0;
    }
    NSString *newString = [string stringByReplacingCharactersInRange:range withString:@""];
    return ([BbParseText countOccurencesOfSubstring:substring beforeSubstring:endString inString:newString]+1);
}

+ (NSString *)matchPattern:(NSString *)pattern inString:(NSString *)string
{
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&err];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if ( nil == matches || matches.count == 0 ) {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:0];
        [results addObject:[string substringWithRange:wordRange]];
    }
    
    return [results componentsJoinedByString:@" "];
}

+ (BOOL)isConnection:(NSString *)string
{
    NSString *pattern = @"#X BbConnection";
    NSString *matches = [BbParseText matchPattern:pattern inString:string];
    return ( nil != matches );
}

+ (BOOL)isParent:(NSString *)string
{
    NSString *pattern = @"#N";
    NSString *matches = [BbParseText matchPattern:pattern inString:string];
    return ( nil != matches );
}

+ (BOOL)isAbstraction:(NSString *)string
{
    BOOL isParent = [BbParseText isParent:string];
    if ( !isParent ) {
        return NO;
    }
    
    NSString *pattern = @"#N BbPatchView";
    NSString *matches = [BbParseText matchPattern:pattern inString:string];
    return ( nil == matches );
}

+ (BOOL)isChild:(NSString *)string
{
    NSString *pattern = @"#X";
    NSString *matches = [BbParseText matchPattern:pattern inString:string];
    return ( nil != matches );
}

+ (BOOL)isSelector:(NSString *)string
{
    NSString *pattern = @"#S";
    NSString *matches = [BbParseText matchPattern:pattern inString:string];
    return  ( nil != matches );
}

+ (NSString *)connectionArgumentsFromString:(NSString *)string
{
    NSString *pattern = @"(?<=#[X]\\sBbConnection\\s)\\d+\\s+\\d+\\s+\\d+\\s+\\d+";
    return [BbParseText matchPattern:pattern inString:string];
}

+ (NSString *)objectArgumentsFromString:(NSString *)string
{
    //NSString *pattern = @"(?<=\\d\\s)Bb(\\w*\\s?)*[^;]";
    //NSString *pattern = @"(?<=\\d\\s)Bb([\\w|\\d|$|:]*\\s?)*[^;]";
    NSString *pattern = @"(?<=\\d\\s)Bb([\\S^;]*\\s?)*(?=;)";
    return [BbParseText matchPattern:pattern inString:string];
}

+ (NSString *)selectorFromString:(NSString *)string
{
    NSString *pattern = @"(?<=#S\\s)(\\w*\\s?)*[^;]";
    return [BbParseText matchPattern:pattern inString:string];
}

+ (NSString *)parentViewArgumentsFromString:(NSString *)string
{
    NSString *pattern = @"(?<=#[NX]\\s)\\w+\\s+[0-9\.\-]+\\s+[0-9\.\-]+\\s+[0-9\.\-]+\\s+[0-9\.\-]+\\s+[0-9\.\-]+\\s+";
    return [BbParseText matchPattern:pattern inString:string];
}

+ (NSString *)childViewArgumentsFromString:(NSString *)string
{
    NSString *pattern = @"(?<=#[NX]\\s)\\w+\\s+[0-9\.\-]+\\s+[0-9\.\-]+\\s+";
    return [BbParseText matchPattern:pattern inString:string];
}

+ (NSUInteger)lengthOfDepth:(NSUInteger)depth inString:(NSString *)string separator:(NSString *)separator
{
    NSUInteger length = 0;
    NSArray *components = [string componentsSeparatedByString:separator];
    NSUInteger previousDepth = depth;
    NSUInteger separatorLength = separator.length;
    for ( NSString *aComponent in components ) {
        NSUInteger newDepth = [BbParseText countOccurencesOfSubstring:@"\t" beforeSubstring:@"#" inString:aComponent];
        length += (aComponent.length);
        if ( newDepth < previousDepth ) {
            break;
        }
        length += separatorLength;
        previousDepth = newDepth;
    }
    
    return length;
}

+ (BbPatchDescription *)parseText:(NSString *)text
{
    BbParseText *parser = [[BbParseText alloc]initWithText:text];
    return [parser parse];
}

+ (NSDictionary *)parseCopiedText:(NSString *)text
{
    BbParseText *parser = [[BbParseText alloc]initWithText:text];
    return [parser parseCopied];
}

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if ( self ) {
        _myText = text;
        _mySeparator = @"\n";
        _myComponents = [_myText componentsSeparatedByString:_mySeparator];
        _myComponentEnumerator = _myComponents.objectEnumerator;
        _myDepth = 0;
        _myTextLocation = 0;
    }
    return self;
}

- (BbPatchDescription *)parse
{
    NSMutableArray *myComponentsCopy = self.myComponents.mutableCopy;
    NSString *myText = [myComponentsCopy firstObject];
    [myComponentsCopy removeObjectAtIndex:0];
    NSUInteger separatorLength = self.mySeparator.length;
    self.myTextLocation += ( myText.length + separatorLength );
    self.myDepth = [BbParseText countOccurencesOfSubstring:@"\t" beforeSubstring:@"#" inString:myText];
    NSString *myTrimmedText = [[myText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@" "];
    myText = myTrimmedText;
    NSString *myViewArgs = [BbParseText parentViewArgumentsFromString:myText];
    if (!myViewArgs) {
        //myViewArgs = @"BbPatchView 2.0 2.0 0.0 0.0 0.5";
    }
    NSString *myObjectArgs = [BbParseText objectArgumentsFromString:myText];
    if (!myObjectArgs) {
        //myObjectArgs = @"BbPatch";
    }
    BbPatchDescription *patchDescription = [BbPatchDescription patchDescriptionWithArgs:myObjectArgs viewArgs:myViewArgs];
    patchDescription.depth = self.myDepth;
    //NSUInteger lineNumber
    while ( self.myTextLocation < self.myText.length ) {
        NSString *myText = [self.myText substringFromIndex:self.myTextLocation];
        NSArray *components = [myText componentsSeparatedByString:self.mySeparator];
        NSString *aComponent = components.firstObject;
        NSUInteger numCharsToAdvance = 0;
        if ( [BbParseText isChild:aComponent] ) {
            if ( [BbParseText isConnection:aComponent] ) {
                [patchDescription addChildConnectionDescriptionWithArgs:[BbParseText connectionArgumentsFromString:aComponent]];
            }else{
                NSString *objectArgs = [BbParseText objectArgumentsFromString:aComponent];
                NSString *viewArgs = [BbParseText childViewArgumentsFromString:aComponent];
                [patchDescription addChildObjectDescriptionWithArgs:objectArgs viewArgs:viewArgs];
            }
            numCharsToAdvance = aComponent.length;
            
        }else if ( [BbParseText isParent:aComponent] ){
            
            if ( [BbParseText isAbstraction:aComponent]) {
                
                NSString *remainingText = [self.myText substringFromIndex:self.myTextLocation];
                NSArray *remainingComponents = [remainingText componentsSeparatedByString:self.mySeparator];
                NSString *myComponent = nil;
                NSUInteger myDepth = 0;
                NSRange myRange;
                myRange.location = self.myTextLocation;
                myRange.length = 0;
                NSUInteger spacerLength = self.mySeparator.length;

                for (NSUInteger i = 0; i < remainingComponents.count; i++) {
                    NSString *component = remainingComponents[i];
                    NSUInteger componentLength = component.length;
                    NSUInteger componentDepth = [BbParseText countOccurencesOfSubstring:@"\t" beforeSubstring:@"#" inString:component];
                    myRange.length+=componentLength;
                    numCharsToAdvance+=componentLength;
                    
                    if (i == 0) {
                        myComponent = component;
                        myDepth = componentDepth;
                        myRange.length+=spacerLength;
                        numCharsToAdvance+=spacerLength;
                    }else{
                        if (componentDepth == myDepth) {
                            break;
                        }else{
                            myRange.length+=spacerLength;
                            numCharsToAdvance+=spacerLength;
                        }
                    }
                }
                
                NSString *abstractionText = [self.myText substringWithRange:myRange];
                NSString *viewArgs = [BbParseText childViewArgumentsFromString:myComponent];
                BbAbstractionDescription *desc = [BbAbstractionDescription abstractionDescriptionWithArgs:abstractionText viewArgs:viewArgs];
                [patchDescription addChildPatchDescription:(BbPatchDescription*)desc];
                
            }else{
                
                NSUInteger depth = [BbParseText countOccurencesOfSubstring:@"\t" beforeSubstring:@"#" inString:aComponent];
                NSUInteger length = [BbParseText lengthOfDepth:depth inString:myText separator:self.mySeparator];
                NSString *substring2 = [myText substringToIndex:length];
                BbPatchDescription *desc = [BbParseText parseText:substring2];
                [patchDescription addChildPatchDescription:desc];
                numCharsToAdvance = length;

            }
            //numCharsToAdvance = length;
        }else if ( [BbParseText isSelector:aComponent] ){
            NSString *selectorArgs = [BbParseText selectorFromString:aComponent];
            [patchDescription addSelectorDescription:selectorArgs];
            numCharsToAdvance = aComponent.length;
        }else{
            
            NSLog(@"INVALID SELECTOR AT LOCATION: %@ COMPONENT: %@",@(self.myTextLocation),aComponent);
        }
        
        self.myTextLocation += (numCharsToAdvance + separatorLength);
    }
    return patchDescription;
}


- (NSDictionary *)parseCopied
{
    NSMutableArray *objectDescriptions = [NSMutableArray array];
    NSMutableArray *connectionDescriptions = [NSMutableArray array];
    NSMutableArray *selectorDescriptions = [NSMutableArray array];
    
    while ( self.myTextLocation < self.myText.length ) {
        NSString *myText = [self.myText substringFromIndex:self.myTextLocation];
        NSArray *components = [myText componentsSeparatedByString:self.mySeparator];
        NSString *aComponent = components.firstObject;
        NSUInteger numCharsToAdvance = 0;
        if ( [BbParseText isChild:aComponent] ) {
            if ( [BbParseText isConnection:aComponent] ) {
                NSString *args = [BbParseText connectionArgumentsFromString:aComponent];
                BbConnectionDescription *connectionDescription = [BbConnectionDescription connectionDescriptionWithArgs:args];
                [connectionDescriptions addObject:connectionDescription];
            }else{
                NSString *objectArgs = [BbParseText objectArgumentsFromString:aComponent];
                NSString *viewArgs = [BbParseText childViewArgumentsFromString:aComponent];
                BbObjectDescription *objectDescription = [BbObjectDescription objectDescriptionWithArgs:objectArgs viewArgs:viewArgs];
                [objectDescriptions addObject:objectDescription];
            }
            numCharsToAdvance = aComponent.length;
            
        }else if ( [BbParseText isParent:aComponent] ){
            NSUInteger depth = [BbParseText countOccurencesOfSubstring:@"\t" beforeSubstring:@"#" inString:aComponent];
            NSUInteger length = [BbParseText lengthOfDepth:depth inString:myText separator:self.mySeparator];
            NSString *substring2 = [myText substringToIndex:length];
            if ( [BbParseText isAbstraction:aComponent]) {
                NSString *viewArgs = [BbParseText childViewArgumentsFromString:aComponent];
                NSRange range = [substring2 rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
                range.location++;
                NSString *objArgs = [substring2 stringByReplacingCharactersInRange:range withString:@""];
                NSString *args = [objArgs trimWhitespace];
                BbAbstractionDescription *desc = [BbAbstractionDescription abstractionDescriptionWithArgs:args viewArgs:viewArgs];
                [objectDescriptions addObject:desc];
            }else{
                BbPatchDescription *desc = [BbParseText parseText:substring2];
                [objectDescriptions addObject:desc];
            }
            numCharsToAdvance = length;
        }else if ( [BbParseText isSelector:aComponent] ){
            NSString *selectorArgs = [BbParseText selectorFromString:aComponent];
            [selectorDescriptions addObject:selectorArgs];
            numCharsToAdvance = aComponent.length;
        }else{
            
            NSLog(@"INVALID SELECTOR AT LOCATION: %@ COMPONENT: %@",@(self.myTextLocation),aComponent);
        }
        
        self.myTextLocation += (numCharsToAdvance + self.mySeparator.length);
    }
    
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    results[kCopiedObjectDescriptionsKey] = objectDescriptions;
    results[kCopiedConnectionDescriptionsKey] = connectionDescriptions;
    results[kCopiedSelectorDescriptionsKey] = selectorDescriptions;
    
    return results;
}

@end
