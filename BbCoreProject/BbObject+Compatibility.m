//
//  BbObject+Compatibility.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/15/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject+Compatibility.h"

@implementation BbObject (Compatibility)

- (BbInlet *)hotInlet
{
    if ( nil == self.inlets || self.inlets.count == 0 ){
        return nil;
    }
    
    return (BbInlet *)(self.inlets[0]);
}

- (BbInlet *)coldInlet
{
    if ( nil == self.inlets || self.inlets.count < 2 ){
        return nil;
    }
    
    return (BbInlet *)(self.inlets[1]);
}

- (BbOutlet *)mainOutlet
{
    if ( nil == self.outlets || self.outlets.count == 0 ) {
        return nil;
    }
    
    return (BbOutlet *)(self.outlets[0]);
}


@end
