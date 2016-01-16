//
//  NSInvocation+BbRuntime.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "NSInvocation+BbRuntime.h"
#import "BbRuntimeLookup.h"
#import "NSValue+Array.h"

typedef NS_ENUM(NSInteger, ArgType) {
    ArgType_Unknown             =   -1,
    ArgType_Nil                 =   0,
    ArgType_SingleObject        =   1,
    ArgType_SingleObjectArray   =   2,
    ArgType_MultiObjectArray    =   3,
    ArgType_StructAsArray       =   4
};

@implementation NSInvocation (BbRuntime)

- (NSString *)getTypeString
{
    NSMutableString *typeString = [NSMutableString stringWithString:[BbRuntimeLookup encoding2String:[self.methodSignature methodReturnType]]];
                                   
    for (NSUInteger i = 0; i < [self.methodSignature numberOfArguments]; i++) {
        [typeString appendString:[BbRuntimeLookup encoding2String:[self.methodSignature getArgumentTypeAtIndex:i]]];
    }
    
    return [NSString stringWithString:typeString];
}

- (id)getReturnValueObject
{
    NSString *encodingString = [BbRuntimeLookup encoding2String:[self.methodSignature methodReturnType]];
    id result = nil;
    BbType type = [BbRuntimeLookup typeFromEncodingString:encodingString];
    switch (type) {
        case BbType_Void:
        {
            result = nil;
        }
            break;
        case BbType_Object:
        {
            void *argVal = nil;
            [self getReturnValue:&argVal];
            result = (__bridge NSObject *)argVal;
        }
            break;
        case BbType_Bool:
        {
            BOOL argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithBool:argVal];
        }
            break;
        case BbType_Int:
        {
            int argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithInt:argVal];
        }
            break;
        case BbType_Float:
        {
            float argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithFloat:argVal];
        }
            break;
        case BbType_Double:
        {
            double argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithDouble:argVal];
        }
            break;
        case BbType_Unsigned:
        {
            unsigned argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithUnsignedLong:argVal];
        }
            break;
        case BbType_Long:
        {
            long argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithLong:argVal];
        }
            break;
        case BbType_LongLong:
        {
            long long argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithLongLong:argVal];
        }
            break;
        case BbType_Rect:
        {
            CGRect argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithCGRect:argVal];
        }
            break;
        case BbType_Point:
        {
            CGPoint argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithCGPoint:argVal];
        }
            break;
        case BbType_Size:
        {
            CGSize argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithCGSize:argVal];
        }
            break;
        case BbType_Integer:
        {
            NSInteger argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithInteger:argVal];
        }
            break;
        case BbType_UInteger:
        {
            NSUInteger argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithUnsignedInteger:argVal];
        }
            break;
        case BbType_CGFloat:
        {
            CGFloat argVal;
            [self getReturnValue:&argVal];
            result = [NSNumber numberWithDouble:argVal];
        }
            break;
        case BbType_Range:
        {
            NSRange argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithRange:argVal];
        }
            break;
        case BbType_EdgeInsets:
        {
            UIEdgeInsets argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithUIEdgeInsets:argVal];
        }
            break;
        case BbType_AffineTransform:
        {
            CGAffineTransform argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithCGAffineTransform:argVal];
        }
            break;
        case BbType_Transform3D:
        {
            CATransform3D argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithCATransform3D:argVal];
        }
            break;
        case BbType_Coordinate2D:
        {
            CLLocationCoordinate2D argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithMKCoordinate:argVal];
        }
            break;
        case BbType_CoordinateSpan:
        {
            MKCoordinateSpan argVal;
            [self getReturnValue:&argVal];
            result = [NSValue valueWithMKCoordinateSpan:argVal];
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    return result;

}

- (NSArray *)getArgumentObjects
{
    NSUInteger numArgs = [self.methodSignature numberOfArguments];
    NSUInteger numVisibleArgs = numArgs-2;
    if ( !numVisibleArgs ) {
        return nil;
    }
    
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:numVisibleArgs];
    for ( NSUInteger i = 2 ; i < numArgs ; i ++ ) {
        id anArg = [self getObjectArgumentAtIndex:i];
        if ( nil != anArg ) {
            [temp addObject:anArg];
        }
    }
    return [NSArray arrayWithArray:temp];
}

- (id)getObjectArgumentAtIndex:(NSUInteger)index
{
    if ( index >= [self.methodSignature numberOfArguments] ) {
        return nil;
    }
    
    NSString *encodingString = [BbRuntimeLookup encoding2String:[self.methodSignature getArgumentTypeAtIndex:index]];
    id result = nil;
    BbType type = [BbRuntimeLookup typeFromEncodingString:encodingString];
    switch (type) {
        case BbType_Void:
        {
            result = nil;
        }
            break;
        case BbType_Object:
        {
            void *argVal = nil;
            [self getArgument:&argVal atIndex:index];
            result = (__bridge NSObject *)argVal;
        }
            break;
        case BbType_Bool:
        {
            BOOL argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithBool:argVal];
        }
            break;
        case BbType_Int:
        {
            int argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithInt:argVal];
        }
            break;
        case BbType_Float:
        {
            float argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithFloat:argVal];
        }
            break;
        case BbType_Double:
        {
            double argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithDouble:argVal];
        }
            break;
        case BbType_Unsigned:
        {
            unsigned argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithUnsignedLong:argVal];
        }
            break;
        case BbType_Long:
        {
            long argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithLong:argVal];
        }
            break;
        case BbType_LongLong:
        {
            long long argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithLongLong:argVal];
        }
            break;
        case BbType_Rect:
        {
            CGRect argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithCGRect:argVal];
        }
            break;
        case BbType_Point:
        {
            CGPoint argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithCGPoint:argVal];
        }
            break;
        case BbType_Size:
        {
            CGSize argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithCGSize:argVal];
        }
            break;
        case BbType_Integer:
        {
            NSInteger argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithInteger:argVal];
        }
            break;
        case BbType_UInteger:
        {
            NSUInteger argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithUnsignedInteger:argVal];
        }
            break;
        case BbType_CGFloat:
        {
            CGFloat argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSNumber numberWithDouble:argVal];
        }
            break;
        case BbType_Range:
        {
            NSRange argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithRange:argVal];
        }
            break;
        case BbType_EdgeInsets:
        {
            UIEdgeInsets argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithUIEdgeInsets:argVal];
        }
            break;
        case BbType_AffineTransform:
        {
            CGAffineTransform argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithCGAffineTransform:argVal];
        }
            break;
        case BbType_Transform3D:
        {
            CATransform3D argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithCATransform3D:argVal];
        }
            break;
        case BbType_Coordinate2D:
        {
            CLLocationCoordinate2D argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithMKCoordinate:argVal];
        }
            break;
        case BbType_CoordinateSpan:
        {
            MKCoordinateSpan argVal;
            [self getArgument:&argVal atIndex:index];
            result = [NSValue valueWithMKCoordinateSpan:argVal];
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    return result;
}

- (void)setArgumentAtIndex:(NSUInteger)index withObject:(id)object
{
    if ( index >= [self.methodSignature numberOfArguments] ) {
        return;
    }
    
    NSString *encodingString = [BbRuntimeLookup encoding2String:[self.methodSignature getArgumentTypeAtIndex:index]];
    id arg = object;
    BbType type = [BbRuntimeLookup typeFromEncodingString:encodingString];
    
    switch (type) {
        case BbType_Void:
        {}
            break;
        case BbType_Object:
        {
            id argVal = arg;
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Bool:
        {
            BOOL argVal = [arg boolValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Int:
        {
            int argVal = [arg intValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Float:
        {
            float argVal = [arg floatValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Double:
        {
            double argVal = [arg doubleValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Unsigned:
        {
            unsigned argVal = [arg unsignedIntValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Long:
        {
            long argVal = [arg longValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_LongLong:
        {
            long long argVal = [arg longLongValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Rect:
        {
            CGRect argVal = [arg CGRectValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Point:
        {
            CGPoint argVal = [arg CGPointValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Size:
        {
            CGSize argVal = [arg CGSizeValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Integer:
        {
            NSInteger argVal  = [arg integerValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_UInteger:
        {
            NSUInteger argVal = [arg unsignedIntegerValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_CGFloat:
        {
            CGFloat argVal = [arg doubleValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Range:
        {
            NSRange argVal = [arg rangeValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_EdgeInsets:
        {
            UIEdgeInsets argVal = [arg UIEdgeInsetsValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_AffineTransform:
        {
            CGAffineTransform argVal = [arg CGAffineTransformValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Transform3D:
        {
            CATransform3D argVal = [arg CATransform3DValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_Coordinate2D:
        {
            CLLocationCoordinate2D argVal = [arg MKCoordinateValue];
            [self setArgument:&argVal atIndex:index];
        }
            break;
        case BbType_CoordinateSpan:
        {
            MKCoordinateSpan argVal = [arg MKCoordinateSpanValue];;
            [self setArgument:&argVal atIndex:index];
        }
            break;
        default:
        {
            
        }
            break;
    }
}

- (void)setArgumentAtIndex:(NSUInteger)index withArray:(NSArray *)array
{
    if ( index >= [self.methodSignature numberOfArguments] ) {
        return;
    }
    
    NSValue *value = [NSValue valueWithArray:array objCType:[self.methodSignature getArgumentTypeAtIndex:index]];
    [self setArgumentAtIndex:index withObject:value];
}

- (ArgType)getArgTypeForObjects:(id)objects
{
    id arg = objects;
    
    if ( nil == arg ) {
        return ArgType_Nil;
    }
    
    if ( ![arg isKindOfClass:[NSArray class]] ) {
        return ArgType_SingleObject;
    }
    
    NSArray *arr = arg;
    
    if ( arr.count == 1 ) {
        return ArgType_SingleObjectArray;
    }
    
    NSUInteger numVisibleArgs = [self.methodSignature numberOfArguments]-2;
    
    if ( numVisibleArgs == arr.count ) {
        return ArgType_MultiObjectArray;
    }
    
    if ( numVisibleArgs == 1 && arr.count > 1 ) {
        return ArgType_StructAsArray;
    }
    
    return ArgType_Unknown;
    
}

- (void)setArgumentsWithObjects:(id)objects
{
    ArgType argType = [self getArgTypeForObjects:objects];
    if ( argType == ArgType_Unknown ) {
        return;
    }
    
    switch (argType) {
        case ArgType_SingleObject:
        {
            [self setArgumentAtIndex:2 withObject:objects];
        }
            break;
        case ArgType_SingleObjectArray:
        {
            NSArray *arr = objects;
            [self setArgumentAtIndex:2 withObject:arr.firstObject];
        }
            break;
        case ArgType_MultiObjectArray:
        {
            NSEnumerator *enumerator = [(NSArray *)objects objectEnumerator];
            for (NSUInteger i = 2; i < [self.methodSignature numberOfArguments] ; i ++ ) {
                [self setArgumentAtIndex:i withObject:[enumerator nextObject]];
            }
        }
            break;
        case ArgType_StructAsArray:
        {
            [self setArgumentAtIndex:2 withArray:objects];
        }
            break;
            
        default:
            break;
    }
}


@end
