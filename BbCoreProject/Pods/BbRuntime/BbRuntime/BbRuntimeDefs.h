//
//  BbRuntimeDefs.h
//  BbRuntime
//
//  Created by Travis Henspeter on 1/5/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#ifndef BbRuntimeDefs_h
#define BbRuntimeDefs_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <objc/runtime.h>


typedef NS_ENUM(NSInteger, BbType)
{
    BbType_Unknown          =   -1,
    BbType_Void             =   0,
    BbType_Object           =   1,
    BbType_Bool             =   2,
    BbType_Int              =   3,
    BbType_Float            =   4,
    BbType_Double           =   5,
    BbType_Unsigned         =   6,
    BbType_Long             =   7,
    BbType_LongLong         =   8,
    BbType_Rect             =   9,
    BbType_Point            =   10,
    BbType_Size             =   11,
    BbType_Integer          =   12,
    BbType_UInteger         =   13,
    BbType_CGFloat          =   14,
    BbType_Range            =   15,
    BbType_EdgeInsets       =   16,
    BbType_AffineTransform  =   17,
    BbType_Transform3D      =   18,
    BbType_Coordinate2D     =   19,
    BbType_CoordinateSpan   =   20,
};



#endif /* BbRuntimeDefs_h */
