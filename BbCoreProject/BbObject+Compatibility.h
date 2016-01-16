//
//  BbObject+Compatibility.h
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/15/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbObject (Compatibility)

- (BbInlet *)hotInlet;

- (BbInlet *)coldInlet;

- (BbOutlet *)mainOutlet;

- (void)setName:(NSString *)name;
- (BbPortInputBlock)calculateOutputBlock:(BbInlet *)inlet;
- (BbPortInputBlock)hotInletRecivedValueBlock:(BbInlet *)inlet;
- (BbPortInputBlock)hotInletReceivedBangBlock:(BbInlet *)inlet;

@end
