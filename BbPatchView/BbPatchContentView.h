//
//  BbPatchContentView.h
//  Pods
//
//  Created by Travis Henspeter on 1/21/16.
//
//

#import <UIKit/UIKit.h>

@interface BbPatchContentView : UIView

@property (nonatomic,strong)        UIBezierPath        *activePath;

- (void)drawConnectionPaths:(NSArray *)paths;

@end
