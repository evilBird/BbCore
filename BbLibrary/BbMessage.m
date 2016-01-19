//
//  BbMessage.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbMessage.h"

@interface BbMessage () <BbObjectViewEditingDelegate>

@property (nonatomic,strong)    NSMapTable      *placeholderMappings;
@property (nonatomic,strong)    NSArray         *myDefaultOutput;

@end

@implementation BbMessage

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hotInlet = YES;
    [self addChildObject:hotInlet];
    
    __block BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildObject:mainOutlet];
    
    __weak BbMessage *weakself = self;
    
    [hotInlet setInputBlock:[BbPort allowTypesInputBlock:@[[NSArray class],[BbBang class]]]];
    
    [hotInlet setOutputBlock:^(id value){
        if ( ![value isKindOfClass:[NSArray class]]) {
            [weakself.view setHighlightView:YES];
            mainOutlet.inputElement = [weakself defaultOutput];
        }else{
            mainOutlet.inputElement = [weakself outputForInput:value];
        }
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"";
    self.displayText = arguments;
    [self updateDefaultOutputAndPlaceholderMapWithText:self.displayText];
}

- (NSArray *)outputForInput:(NSArray *)value
{
    if ( [value.firstObject isKindOfClass:[NSString class]] && [value.firstObject isEqualToString:@"set"]) {
        if ( value.count == 1 ) {
            self.objectArguments = nil;
            self.displayText = @"";
            [self.view setTitleText:self.displayText];
            [self updateDefaultOutputAndPlaceholderMapWithText:self.displayText];
            return nil;
        }else{
            NSMutableArray *toSet = value.mutableCopy;
            [toSet removeObjectAtIndex:0];
            self.objectArguments = [toSet componentsJoinedByString:@" "];
            self.displayText = self.objectArguments;
            [self.view setTitleText:self.displayText];
            [self updateDefaultOutputAndPlaceholderMapWithText:self.displayText];
            return nil;
        }
    }else if ( nil != self.placeholderMappings ){
        NSEnumerator *keys = [self.placeholderMappings keyEnumerator];
        NSMutableArray *substitutedArray = self.myDefaultOutput.mutableCopy;
        BOOL sendOnDone = NO;
        for (NSNumber *aKey in keys ) {
            NSUInteger myIndex = aKey.integerValue;
            NSUInteger theirIndex = [[self.placeholderMappings objectForKey:aKey]integerValue];
            if ( myIndex < self.myDefaultOutput.count && theirIndex < value.count ) {
                sendOnDone = YES;
                [substitutedArray replaceObjectAtIndex:myIndex withObject:value[theirIndex]];
            }
        }
        
        if ( sendOnDone ) {
            return [NSArray arrayWithArray:substitutedArray];
        }
    }
    
    return nil;
}


- (void)updateDefaultOutputAndPlaceholderMapWithText:(NSString *)text
{
    if ( nil == text ) {
        return;
    }
    
    self.placeholderMappings = nil;
    self.objectArguments = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.myDefaultOutput = [BbObject text2Array:text];
    
    if ( ![text containsString:@"$"] ) {
        return;
    }
    
    NSCharacterSet *whiteSpaceCharSet = [NSCharacterSet whitespaceCharacterSet];
    NSArray *textComponents = [text componentsSeparatedByCharactersInSet:whiteSpaceCharSet];
    NSCharacterSet *integerCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *nonIntegerCharSet = [integerCharSet invertedSet];
    NSUInteger myIndex = 0;
    for (NSString *aComponent in textComponents.mutableCopy ) {
        NSString *trimmedComponent = [aComponent stringByTrimmingCharactersInSet:whiteSpaceCharSet];
        if ( [trimmedComponent hasPrefix:@"$"] && trimmedComponent.length > 1 ) {
            NSString *digits = [trimmedComponent substringFromIndex:1];
            if ( [digits rangeOfCharacterFromSet:nonIntegerCharSet].length == 0) {
                NSUInteger theirIndex = [digits integerValue];
                if ( theirIndex > 0 ) {
                    if ( nil == self.placeholderMappings ) {
                        self.placeholderMappings = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsCopyIn];
                    }
                    [self.placeholderMappings setObject:@( theirIndex - 1 ) forKey:@( myIndex )];
                }
            }
        }
        
        myIndex++;
    }

}

- (NSArray *)defaultOutput
{
    if ( nil != self.objectArguments ) {
        return self.myDefaultOutput;
    }
    
    return nil;
}

- (void)sendActionsForObjectView:(id<BbObjectView>)sender
{
    BbBang *aBang = [BbBang bang];
    [self.inlets[0] setInputElement:aBang];
}

- (NSString *)titleTextForObjectView:(id<BbObjectView>)objectView
{
    return self.displayText;
}

+ (NSString *)symbolAlias
{
    return @"message";
}

+ (NSString *)viewClass
{
    return @"BbMessageView";
}

- (void)objectView:(id<BbObjectView>)sender userEnteredText:(NSString *)text
{
    self.displayText = text;
    [self updateDefaultOutputAndPlaceholderMapWithText:text];
    NSLog(@"DO SOMETHING WITH TEXT: %@",text);
}

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithText:(NSString *)text
{
    text;
    return YES;
}

@end
