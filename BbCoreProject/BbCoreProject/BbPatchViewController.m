//
//  BbPatchViewController.m
//  BbBridge
//
//  Created by Travis Henspeter on 1/12/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatchViewController.h"
#import "BbPatchController.h"
#import "UIView+Layout.h"

@interface BbPatchViewController () <BbPatchControllerDelegate>

@property (nonatomic,strong)        BbPatchController           *patchController;

@end

@implementation BbPatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPatchText:(NSString *)patchText
{
    _patchText = patchText;
    [self setupPatchControllerWithText:patchText];
}

- (void)setupPatchControllerWithText:(NSString *)text
{
    self.patchController = [[BbPatchController alloc]initWithText:text delegate:self];
    __weak BbPatchViewController *weakself = self;
    [self.patchController loadPatchCompletion:^{
        [weakself.patchController loadViewsCompletion:^{
            
        }];
    }];
}

- (void)addObjectView:(id)objectView
{
    UIView *aView = objectView;
    [self.view addSubview:aView];
    [self.view addConstraints:[aView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
    [self.view layoutIfNeeded];
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
