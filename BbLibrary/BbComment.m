//
//  BbComment.m
//  Pods
//
//  Created by Travis Henspeter on 2/8/16.
//
//

#import "BbComment.h"

@interface BbComment () <BbObjectViewEditingDelegate>

@end

@implementation BbComment

+ (NSString *)viewClass
{
    return @"BbCommentView";
}

+ (NSString *)symbolAlias
{
    return @"comment";
}

- (void)setupPorts {}

- (void)setupWithArguments:(id)arguments
{
    self.displayText = arguments;
}

- (id<BbObjectViewEditingDelegate>)editingDelegateForObjectView:(id<BbObjectView>)sender
{
    return self;
}

- (NSString *)objectView:(id<BbObjectView>)sender suggestCompletionForUserText:(NSString *)userText
{
    return @"";
}

- (BOOL)objectView:(id<BbObjectView>)sender shouldEndEditingWithUserText:(NSString *)userText
{
    return YES;
}

- (void)objectView:(id<BbObjectView>)sender didEndEditingWithUserText:(NSString *)userText
{
    self.displayText = userText;
    self.creationArguments = userText;
    [sender updateAppearance];
}

- (BOOL)canEdit
{
    return YES;
}

- (BOOL)canOpen
{
    return NO;
}

@end
