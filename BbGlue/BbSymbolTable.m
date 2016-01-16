//
//  BbSymbolTable.m
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbSymbolTable.h"
#import "BbRuntimeLookup.h"
#import "BbObject.h"

@interface BbSymbolTable ()

@property (nonatomic,strong)            NSArray             *registeredClassNames;
@property (nonatomic,strong)            NSDictionary        *objectSymbolDictionary;
@property (nonatomic,strong)            NSSet               *objectSearchKeywords;
@property (nonatomic,strong)            NSPredicate         *searchPredicate;

@end

@implementation BbSymbolTable

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        [self defaultInit];
    }
    
    return self;
}

- (void)defaultInit
{
    self.registeredClassNames = [BbRuntimeLookup getClassNames];
    self.objectSymbolDictionary = [self generateBbObjectSymbolDictionary];
    self.objectSearchKeywords = [NSSet setWithArray:self.objectSymbolDictionary.allKeys];
}

- (NSArray *)ClassNamesMatchingPattern:(NSString *)pattern
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",pattern];
    return [self.registeredClassNames filteredArrayUsingPredicate:predicate];
}

- (NSArray *)BbObjectClassNames
{
    NSString *pattern = @"Bb*";
    NSArray *classNames = [self ClassNamesMatchingPattern:pattern];
    NSSet *dedupedClassNames = [NSSet setWithArray:classNames];
    NSMutableArray *results = [NSMutableArray array];
    Class BbObjectClass = NSClassFromString(@"BbObject");
    for ( NSString *aClassName in dedupedClassNames.allObjects ) {
        Class aClass = NSClassFromString(aClassName);
        Class superClass = class_getSuperclass(aClass);

        if ( superClass == BbObjectClass ) {
            [results addObject:aClassName];
        }
        
    }
    return results;
}

- (NSDictionary *)generateBbObjectSymbolDictionary
{
    NSArray *BbClassNames = [self BbObjectClassNames];
    NSMutableDictionary *symbolDictionary = [NSMutableDictionary dictionary];
    for (NSString *aClassName in BbClassNames ) {
        NSString *mainKey = [aClassName lowercaseString];
        NSAssert([symbolDictionary.allKeys containsObject:mainKey]==NO, @"DUPLICATE SYMBOL %@",mainKey);
        symbolDictionary[mainKey] = aClassName;
        NSString *aliasKey = [[NSInvocation doClassMethod:aClassName selector:@"symbolAlias" arguments:nil]lowercaseString];
        if ( nil != aliasKey && ![aliasKey isEqualToString:mainKey] ) {
            NSAssert([symbolDictionary.allKeys containsObject:aliasKey] == NO, @"DUPLICATE SYMBOL ALIAS %@",aliasKey);
            symbolDictionary[aliasKey] = aClassName;
        }
    }
    
    return symbolDictionary;
}

- (NSArray *)searchForText:(NSString *)text inKeywordArray:(NSArray *)keywords sortAscending:(BOOL)ascending onKey:(NSString *)sortKey maxResults:(NSUInteger)maxResults
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",text];
    NSArray *filtered = [keywords filteredArrayUsingPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending];
    NSArray *sorted = [filtered sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSRange range;
    range.location = 0;
    range.length = ( sorted.count > maxResults ) ? ( maxResults ) : ( sorted.count );
    return [sorted objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
}

#pragma mark - BbTextCompletionDataSource

- (NSArray *)BbText:(id)sender searchKeywordsForText:(NSString *)text
{
    NSString *searchTerm = [NSString stringWithFormat:@"%@*",[text lowercaseString]];
    NSArray *searchResults = [self searchForText:searchTerm
                                  inKeywordArray:self.objectSearchKeywords.allObjects
                                   sortAscending:YES onKey:@"length"
                                      maxResults:3];
    return searchResults;
}

- (BOOL)BbText:(id)sender symbolExistsForKeyword:(NSString *)keyword
{
    if ( nil == keyword ) {
        return NO;
    }
    
    return [self.objectSearchKeywords containsObject:keyword];
}

- (NSString *)BbText:(id)sender symbolForKeyword:(NSString *)keyword
{
    if ( ![self BbText:sender symbolExistsForKeyword:[keyword lowercaseString]] ) {
        return nil;
    }
    
    return self.objectSymbolDictionary[[keyword lowercaseString]];
}

@end
