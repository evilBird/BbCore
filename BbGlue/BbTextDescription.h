//
//  BbTextDescription.h
//  Pods
//
//  Created by Travis Henspeter on 1/10/16.
//
//

#import <Foundation/Foundation.h>

@interface BbConnectionDescription : NSObject

@property (nonatomic)           NSUInteger      senderParentIndex;
@property (nonatomic)           NSUInteger      senderPortIndex;
@property (nonatomic)           NSUInteger      receiverParentIndex;
@property (nonatomic)           NSUInteger      receiverPortIndex;


+ (BbConnectionDescription *)connectionDescriptionWithArgs:(NSString *)argString;
- (NSString *)humanReadableText;

@end

@interface BbObjectDescription : NSObject

@property (nonatomic,strong)    NSString        *objectClass;
@property (nonatomic,strong)    NSString        *objectArguments;
@property (nonatomic,strong)    NSString        *viewClass;
@property (nonatomic,strong)    NSString        *viewArguments;

+ (BbObjectDescription *)objectDescriptionWithArgs:(NSString *)objectArgs viewArgs:(NSString *)viewArgs;
- (NSString *)humanReadableText;

@end

@interface BbPatchDescription : BbObjectDescription

@property (nonatomic)           NSUInteger              depth;
@property (nonatomic,strong)    NSMutableArray         *childObjectDescriptions;
@property (nonatomic,strong)    NSMutableArray         *childConnectionDescriptions;
@property (nonatomic,strong)    NSMutableArray         *selectorDescriptions;

+ (BbPatchDescription *)patchDescriptionWithArgs:(NSString *)objectArgs viewArgs:(NSString *)viewArgs;

- (void)addChildObjectDescriptionWithArgs:(NSString *)objectArgs viewArgs:(NSString *)viewArgs;
- (void)addChildPatchDescription:(BbPatchDescription *)patchDescription;
- (void)addChildConnectionDescriptionWithArgs:(NSString *)connectionArgs;
- (void)addSelectorDescription:(NSString *)selectorArgs;

@end

@interface BbAbstractionDescription : BbPatchDescription


@end