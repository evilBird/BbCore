//
//  BbImpBlock.m
//  BbRuntime
//
//  Created by Travis Henspeter on 1/6/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeImpBlock.h"
#import "BbRuntimeDefs.h"
#import "BbRuntimeLookup.h"

typedef void                    (^BbReturnVoidBlock)                (void);
typedef id                      (^BbReturnIdBlock)                  (void);
typedef BOOL                    (^BbReturnBoolBlock)                (void);
typedef int                     (^BbReturnIntBlock)                 (void);
typedef float                   (^BbReturnFloatBlock)               (void);
typedef double                  (^BbReturnDoubleBlock)              (void);
typedef unsigned                (^BbReturnUnsignedBlock)            (void);
typedef long                    (^BbReturnLongBlock)                (void);
typedef long long               (^BbReturnLongLongBlock)            (void);
typedef CGRect                  (^BbReturnCGRectBlock)              (void);
typedef CGPoint                 (^BbReturnCGPointBlock)             (void);
typedef CGSize                  (^BbReturnCGSizeBlock)              (void);
typedef CGFloat                 (^BbReturnCGFloatBlock)             (void);
typedef NSUInteger              (^BbReturnNSUIntegerBlock)          (void);
typedef NSInteger               (^BbReturnNSIntegerBlock)           (void);
typedef CATransform3D           (^BbReturnCATransform3DBlock)       (void);
typedef CGAffineTransform       (^BbReturnCGAffineTransformBlock)   (void);
typedef CLLocationCoordinate2D  (^BbReturnCoordinateBlock)          (void);
typedef NSRange                 (^BbReturnRangeBlock)               (void);
typedef UIEdgeInsets            (^BbReturnInsetsBlock)              (void);
typedef MKCoordinateSpan        (^BbReturnCoordinateSpanBlock)      (void);

@implementation BbRuntimeImpBlock

+ (id)impBlockWithReturnValue:(id)returnVal type:(NSString *)returnType
{
    BbType type = [BbRuntimeLookup  typeFromEncodingString:returnType];
    
    switch (type) {
        case BbType_Void:
        {
            BbReturnVoidBlock block = ^(void){
                return;
            };
            return block;
        }
            break;
        case BbType_Object:
        {
            BbReturnIdBlock block = ^(void){
                return returnVal;
            };
            return block;
        }
            break;
        case BbType_Bool:
        {
            BbReturnBoolBlock block = ^(void){
                if ( nil == returnVal ) {
                    return NO;
                }
                
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return [value boolValue];
            };
            return block;
        }
            break;
        case BbType_Int:
        {
            BbReturnIntBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((int)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((int)[value intValue]);
            };
            return block;
        }
            break;
        case BbType_Float:
        {
            BbReturnFloatBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((float)0.0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((float)[value floatValue]);
            };
            return block;
        }
            break;
        case BbType_Double:
        {
            BbReturnDoubleBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((double)0.0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((double)[value doubleValue]);
            };
            return block;
        }
            break;
        case BbType_Unsigned:
        {
            BbReturnUnsignedBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((unsigned)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((unsigned)[value unsignedIntValue]);
            };
            return block;
        }
            break;
        case BbType_Long:
        {
            BbReturnLongBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((long)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((long)[value longValue]);
            };
            return block;
        }
            break;
        case BbType_LongLong:
        {
            BbReturnLongLongBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((long long)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((long long)[value longLongValue]);
            };
            return block;
        }
            break;
        case BbType_Rect:
        {
            BbReturnCGRectBlock block = ^(void){
                if ( nil == returnVal ) {
                    return (CGRectZero);
                }
                NSValue *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSValue *)returnVal;
                return [value CGRectValue];
            };
            return block;
        }
            break;
        case BbType_Point:
        {
            BbReturnCGPointBlock block = ^(void){
                if ( nil == returnVal ) {
                    return (CGPointZero);
                }
                NSValue *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSValue *)returnVal;
                return [value CGPointValue];
            };
            return block;
        }
            break;
        case BbType_Size:
        {
            BbReturnCGSizeBlock block = ^(void){
                if ( nil == returnVal ) {
                    return (CGSizeZero);
                }
                NSValue *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSValue *)returnVal;
                return [value CGSizeValue];
            };
            return block;
        }
            break;
        case BbType_Integer:
        {
            BbReturnNSIntegerBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((NSInteger)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((NSInteger)[value integerValue]);
            };
            return block;
        }
            break;
        case BbType_UInteger:
        {
            BbReturnNSUIntegerBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((NSUInteger)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((NSUInteger)[value unsignedIntegerValue]);
            };
            return block;
        }
            break;
        case BbType_CGFloat:
        {
            BbReturnCGFloatBlock block = ^(void){
                if ( nil == returnVal ) {
                    return ((CGFloat)0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((CGFloat)[value doubleValue]);
            };
            return block;
        }
            break;
        case BbType_Range:
        {
            BbReturnRangeBlock block = ^(void){
                if ( nil == returnVal ) {
                    NSRange range;
                    range.location = 0;
                    range.length = 0;
                    return ((NSRange)range);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((NSRange)[value rangeValue]);
            };
            return block;
        }
            break;
        case BbType_EdgeInsets:
        {
            BbReturnInsetsBlock block = ^(void){
                if ( nil == returnVal ) {
                    return UIEdgeInsetsZero;
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((UIEdgeInsets)[value UIEdgeInsetsValue]);
            };
            return block;
        }
            break;
        case BbType_AffineTransform:
        {
            BbReturnCGAffineTransformBlock block = ^(void){
                if ( nil == returnVal ) {
                    return CGAffineTransformIdentity;
                }
                NSValue *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSValue *)returnVal;
                return ((CGAffineTransform)[value CGAffineTransformValue]);
            };
            return block;
        }
            break;
        case BbType_Transform3D:
        {
            BbReturnCATransform3DBlock block = ^(void){
                if ( nil == returnVal ) {
                    return CATransform3DIdentity;
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((CATransform3D)[value CATransform3DValue]);
            };
            return block;
        }
            break;
        case BbType_Coordinate2D:
        {
            BbReturnCoordinateBlock block = ^(void){
                if ( nil == returnVal ) {
                    return CLLocationCoordinate2DMake(0.0, 0.0);
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return (CLLocationCoordinate2D)[value MKCoordinateValue];
            };
            return block;
        }
            break;
        case BbType_CoordinateSpan:
        {
            BbReturnCoordinateSpanBlock block = ^(void){
                if ( nil == returnVal ) {
                    return (MKCoordinateSpanMake(0.0, 0.0));
                }
                NSNumber *value = ( [returnVal isKindOfClass:[NSArray class]] ) ? ( [(NSArray *)returnVal firstObject] ): (NSNumber *)returnVal;
                return ((MKCoordinateSpan)[value MKCoordinateSpanValue]);
            };
            return block;
        }
            break;
        default:
        {
            BbReturnVoidBlock block = ^(void){
                return;
            };
            return block;
        }
            break;
    }
    
}


@end
