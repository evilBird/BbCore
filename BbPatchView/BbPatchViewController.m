//
//  BbPatchViewController.m
//  BbBridge
//
//  Created by Travis Henspeter on 1/12/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatchViewController.h"
#import "UIView+Layout.h"
#import "BbPatch.h"
#import "BbTextDescription.h"
#import "BbParseText.h"
#import "BbPatchViewContainer.h"
#import "BbPatchView.h"

@interface BbPatchViewController ()

@property (nonatomic,strong)        BbPatchViewContainer        *patchViewContainer;
@property (nonatomic,strong)        BbPatch                     *myPatch;
@property (nonatomic,strong)        NSString                    *myPatchText;

@end

@implementation BbPatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.patchViewContainer = [[BbPatchViewContainer alloc]init];
    self.patchViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.patchViewContainer];
    [self.view addConstraints:[self.patchViewContainer pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPatch:(NSString *)patchTitle withText:(NSString *)patchText completion:(void (^)(void))completion
{
    self.patchTitle = patchTitle;
    self.title = patchTitle;
    self.myPatchText = patchText;
    BbPatchDescription *description = [BbParseText parseText:self.myPatchText];
    BbPatch *myPatch = [BbPatch patchWithDescription:description];
    BbPatchView *myPatchView = [[BbPatchView alloc]initWithDataSource:myPatch];
    myPatchView.delegate = myPatch;
    //myPatchView.translatesAutoresizingMaskIntoConstraints = NO;
    myPatch.view = myPatchView;
    self.myPatch = myPatch;
    __weak BbPatchViewController *weakself = self;
    [self.patchViewContainer setPatchView:myPatchView completion:^{
        [weakself.myPatch doSelectors];
        if ( nil != completion ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
