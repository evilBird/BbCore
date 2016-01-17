//
//  BbMessageView.h
//  Pods
//
//  Created by Travis Henspeter on 1/16/16.
//
//

#import "BbAbstractView.h"

@interface BbMessageView : BbAbstractView

@property (nonatomic,strong)                        UIColor         *highlightedFillColor;
@property (nonatomic,strong)                        UIColor         *highlightedTextColor;
@property (nonatomic,strong)                        UIColor         *highlightedBorderColor;
@property (nonatomic,getter=isHighlighted)          BOOL            highlighted;

@end
