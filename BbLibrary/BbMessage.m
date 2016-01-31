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
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    
    __block BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
    
    __weak BbMessage *weakself = self;
    [hotInlet setInputBlock:[BbPort allowTypesInputBlock:@[[NSArray class],[BbBang class]]]];
    
    [hotInlet setOutputBlock:^(id value){
        if ( ![value isKindOfClass:[NSArray class]]) {
            [weakself.view setHighlighted:YES];
            id defaultOutput = [weakself defaultOutput];
            mainOutlet.inputElement = defaultOutput;
        }else{
            id output = [weakself outputForInput:value];
            mainOutlet.inputElement = output;
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
            self.creationArguments = nil;
            self.displayText = @"";
            [self.view setTitleText:self.displayText];
            [self updateDefaultOutputAndPlaceholderMapWithText:self.displayText];
            return nil;
        }else{
            NSMutableArray *toSet = value.mutableCopy;
            [toSet removeObjectAtIndex:0];
            self.creationArguments = [toSet componentsJoinedByString:@" "];
            self.displayText = self.creationArguments;
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
    }else{
        return [self defaultOutput];
    }
    
    return nil;
}


- (void)updateDefaultOutputAndPlaceholderMapWithText:(NSString *)text
{
    if ( nil == text ) {
        return;
    }
    
    self.placeholderMappings = nil;
    self.creationArguments = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.myDefaultOutput = [text getArguments];
    
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
    if ( nil != self.creationArguments ) {
        return self.myDefaultOutput;
    }
    
    return nil;
}

- (void)sendActionsForView:(id<BbObjectView>)sender
{
    [self.inlets[0] setInputElement:[self.displayText getArguments]];
    [self.view setHighlighted:YES];
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

- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender
{
    return self;
}

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText
{
    return @"";
}

- (BOOL)canEdit
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)sender userEnteredText:(NSString *)text
{
    self.displayText = text;
    [self updateDefaultOutputAndPlaceholderMapWithText:text];
    NSLog(@"DO SOMETHING WITH TEXT: %@",text);
}

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithText:(NSString *)text
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText
{
    self.creationArguments = [userText trimWhitespace];
    self.displayText = self.creationArguments;
    [self updateDefaultOutputAndPlaceholderMapWithText:self.creationArguments];
}

@end
