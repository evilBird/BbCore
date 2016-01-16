//
//  BbObject+BbObjectViewDelegate.m
//  Pods
//
//  Created by Travis Henspeter on 1/12/16.
//
//

#import "BbObject.h"

@implementation BbObject (BbObjectViewDelegate)

- (void)objectView:(id<BbObjectView>)sender didChangePosition:(NSValue *)position
{
    [self setViewArguments:[BbHelpers updateViewArgs:self.viewArguments withPosition:position]];
}

- (void)objectView:(id<BbObjectView>)sender didAddPortView:(id<BbObjectView>)portView inScope:(NSUInteger)scope atIndex:(NSUInteger)index
{
    NSMutableArray *ports = ( scope == 0 ) ? ( self.outlets ) : ( self.inlets );
    if ( index < ports.count ) {
        BbPort *aPort = ports[index];
        aPort.view = portView;
        portView.dataSource = (id<BbObjectViewDataSource>)aPort;
    }
}

@end
