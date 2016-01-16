//
//  BbRuntimeLookup+Types.m
//  BbRuntimeLookup
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbRuntimeLookup.h"


@implementation BbRuntimeLookup (Types)

+ (NSString *)encoding2String:(const char *)encoding
{
    return [NSString stringWithUTF8String:encoding];
}

+ (NSArray *)supportedTypeEncodings
{
    NSArray *supportedTypes = @[
                                [BbRuntimeLookup encoding2String:@encode(void)],
                                [BbRuntimeLookup encoding2String:@encode(id)],
                                [BbRuntimeLookup encoding2String:@encode(BOOL)],
                                [BbRuntimeLookup encoding2String:@encode(int)],
                                [BbRuntimeLookup encoding2String:@encode(float)],
                                [BbRuntimeLookup encoding2String:@encode(double)],
                                [BbRuntimeLookup encoding2String:@encode(unsigned)],
                                [BbRuntimeLookup encoding2String:@encode(long)],
                                [BbRuntimeLookup encoding2String:@encode(long long)],
                                [BbRuntimeLookup encoding2String:@encode(CGRect)],
                                [BbRuntimeLookup encoding2String:@encode(CGPoint)],
                                [BbRuntimeLookup encoding2String:@encode(CGSize)],
                                [BbRuntimeLookup encoding2String:@encode(NSInteger)],
                                [BbRuntimeLookup encoding2String:@encode(NSUInteger)],
                                [BbRuntimeLookup encoding2String:@encode(CGFloat)],
                                [BbRuntimeLookup encoding2String:@encode(NSRange)],
                                [BbRuntimeLookup encoding2String:@encode(UIEdgeInsets)],
                                [BbRuntimeLookup encoding2String:@encode(CGAffineTransform)],
                                [BbRuntimeLookup encoding2String:@encode(CATransform3D)],
                                [BbRuntimeLookup encoding2String:@encode(CLLocationCoordinate2D)],
                                [BbRuntimeLookup encoding2String:@encode(MKCoordinateSpan)]
                                ];
    return supportedTypes;
}

+ (BbType)typeFromEncodingString:(NSString *)string
{
    NSArray *supportedTypes = [BbRuntimeLookup supportedTypeEncodings];
    if ( nil == string || ![supportedTypes containsObject:string] ) {
        return BbType_Unknown;
    }
    
    return [supportedTypes indexOfObject:string];
}

+ (NSUInteger)sizeOfArgType:(const char *)encoding
{
    NSString *encodingString = [NSString stringWithUTF8String:encoding];
    return [BbRuntimeLookup sizeOfType:encodingString];
}

+ (NSUInteger)sizeOfType:(NSString *)encodingString
{
    BbType type = [BbRuntimeLookup typeFromEncodingString:encodingString];
    
    switch (type) {
        case BbType_Void:
            return sizeof(void);
            break;
        case BbType_Object:
            return sizeof(id);
            break;
        case BbType_Bool:
            return sizeof(BOOL);
            break;
        case BbType_Int:
            return sizeof(int);
            break;
        case BbType_Float:
            return sizeof(float);
            break;
        case BbType_Double:
            return sizeof(double);
            break;
        case BbType_Unsigned:
            return sizeof(unsigned);
            break;
        case BbType_Long:
            return sizeof(long);
            break;
        case BbType_LongLong:
            return sizeof(long long);
            break;
        case BbType_Rect:
            return sizeof(CGRect);
            break;
        case BbType_Point:
            return sizeof(CGPoint);
            break;
        case BbType_Size:
            return sizeof(CGSize);
            break;
        case BbType_Integer:
            return sizeof(NSInteger);
            break;
        case BbType_UInteger:
            return sizeof(NSUInteger);
            break;
        case BbType_CGFloat:
            return sizeof(CGFloat);
            break;
        case BbType_Range:
            return sizeof(NSRange);
            break;
        case BbType_EdgeInsets:
            return sizeof(UIEdgeInsets);
            break;
        case BbType_AffineTransform:
            return sizeof(CGAffineTransform);
            break;
        case BbType_Transform3D:
            return sizeof(CATransform3D);
            break;
        case BbType_Coordinate2D:
            return sizeof(CLLocationCoordinate2D);
            break;
        case BbType_CoordinateSpan:
            return sizeof(MKCoordinateSpan);
            break;
        default:
            return 0;
            break;
    }
}

- (void)genericTypeSwitch
{
    BbType type;
    switch (type) {
        case BbType_Void:
        {
        }
            break;
        case BbType_Object:
        {
            
        }
            break;
        case BbType_Bool:
        {
            
        }
            break;
        case BbType_Int:
        {
            
        }
            break;
        case BbType_Float:
        {
            
        }
            break;
        case BbType_Double:
        {
            
        }
            break;
        case BbType_Unsigned:
        {
            
        }
            break;
        case BbType_Long:
        {
            
        }
            break;
        case BbType_LongLong:
        {
            
        }
            break;
        case BbType_Rect:
        {
            
        }
            break;
        case BbType_Point:
        {
            
        }
            break;
        case BbType_Size:
        {
            
        }
            break;
        case BbType_Integer:
        {
            
        }
            break;
        case BbType_UInteger:
        {
            
        }
            break;
        case BbType_CGFloat:
        {
            
        }
            break;
        case BbType_Range:
        {
            
        }
            break;
        case BbType_EdgeInsets:
        {
            
        }
            break;
        case BbType_AffineTransform:
        {
            
        }
            break;
        case BbType_Transform3D:
        {
            
        }
            break;
        case BbType_Coordinate2D:
        {
            
        }
            break;
        case BbType_CoordinateSpan:
        {
            
        }
            break;
        default:
        {
            
        }
            break;
    }
}

@end
