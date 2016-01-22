//
//  BbMessageView.h
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbAbstractView.h"

@interface BbMessageView : BbAbstractView

+ (id<BbObjectView>)viewWithEntity:(id<BbEntity,BbObject>)entity;

@end
