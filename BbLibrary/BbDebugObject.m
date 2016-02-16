//
//  BbDebugObject.m
//  Pods
//
//  Created by Travis Henspeter on 2/12/16.
//
//

#import "BbDebugObject.h"
#import <objc/runtime.h>

@interface NSObject (Obj2Dict)

- (NSDictionary *)asDictionary;

@end

@implementation NSObject (Obj2Dict)

- (NSDictionary *)asDictionary
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:(NSUInteger)count];
    
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *key = property_getName(property);
        NSString *propertyKey = [NSString stringWithUTF8String:key];
        SEL selector = NSSelectorFromString(propertyKey);
        id propertyValue = nil;
        
        
        if (![self respondsToSelector:selector]) {
            
        }else{
            propertyValue = [self valueForKey:propertyKey];
        }
        
        if (propertyValue) {
            if ([propertyValue respondsToSelector:@selector(asDictionary)]) {
                NSDictionary *propertyDict = [propertyValue asDictionary];
                if (propertyDict.allValues.count) {
                    [temp setObject:propertyDict forKey:propertyKey];
                }else{
                    [temp setObject:propertyValue forKey:propertyKey];
                }
            }else{
                [temp setObject:propertyValue forKey:propertyKey];
            }
        }
    }
    
    free(properties);
    Class c = object_getClass(self);
    Ivar *ivars = class_copyIvarList(c, &count);
    
    for (int i = 0; i < count; i ++) {
        Ivar anIvar = ivars[i];
        const char *ivarname = ivar_getName(anIvar);
        NSString *ivarName = [NSString stringWithUTF8String:ivarname];
        const char *encoding = ivar_getTypeEncoding(anIvar);
        NSString *ivarEncoding = [NSString stringWithUTF8String:encoding];
        if ([ivarEncoding isEqualToString:@"@"]) {
            id value = object_getIvar(self, anIvar);
            
            if ([value respondsToSelector:@selector(asDictionary)]) {
                NSDictionary *ivarDict = [value asDictionary];
                if (ivarDict.allValues.count) {
                    [temp setObject:ivarDict forKey:ivarName];
                }else{
                    [temp setObject:value forKey:ivarName];
                }
            }else{
                [temp setObject:value forKey:ivarName];
            }
        }else if ([ivarEncoding containsString:@"NSMutableArray"]){
            NSMutableArray *value = object_getIvar(self, anIvar);
            [temp setObject:value forKey:ivarName];
        }
        
        
    }
    free(ivars);
    
    return [NSDictionary dictionaryWithDictionary:temp];
}

@end

@implementation BbDebugObject

+ (NSString *)symbolAlias
{
    return @"debug";
}

- (void)setupPorts
{
    BbInlet *hotInlet = [[BbInlet alloc]init];
    hotInlet.hot = YES;
    [self addChildEntity:hotInlet];
    __block BbOutlet *mainOutlet = [[BbOutlet alloc]init];
    [self addChildEntity:mainOutlet];
    __block NSDictionary *objectMap;
    [hotInlet setOutputBlock:^(id value){
        objectMap = [value asDictionary];
        [mainOutlet setInputElement:objectMap];
    }];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"debug";
    self.displayText = self.name;
}

- (NSDictionary *)object2Dictionary
{
    return nil;
}

@end
