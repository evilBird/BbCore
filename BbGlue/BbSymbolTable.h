//
//  BbSymbolTable.h
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import <Foundation/Foundation.h>
#import "BbCoreProtocols.h"
@protocol BbTextCompletionDataSource <NSObject>

- (NSArray *)BbText:(id)sender searchKeywordsForText:(NSString *)text;
- (NSArray *)BbText:(id)sender searchObjectsForText:(NSString *)text;
- (NSArray *)BbText:(id)sender searchPatchesForText:(NSString *)text;

- (NSArray *)BbText:(id)sender searchMethodsForText:(NSString *)text;

- (BOOL)BbText:(id)sender symbolExistsForKeyword:(NSString *)keyword;
- (NSString *)BbText:(id)sender symbolForKeyword:(NSString *)keyword;

@end

@interface BbSymbolTable : NSObject <BbTextCompletionDataSource>

- (instancetype)initWithDataSource:(id<BbObjectDataSource>)dataSource;

@property (nonatomic,weak)          id<BbObjectDataSource>  dataSource;
@property (nonatomic,strong)        NSHashTable             *BbObjectsTable;
@property (nonatomic,strong)        NSHashTable             *BbPatchesTable;

- (NSArray *)ClassNamesMatchingPattern:(NSString *)pattern;
- (NSArray *)BbObjectClassNames;

@end
