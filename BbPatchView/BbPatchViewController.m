//
//  BbPatchViewController.m
//  BbBridge
//
//  Created by Travis Henspeter on 1/12/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "BbPatchViewController.h"
#import "BbScrollView.h"
#import "BbPatchView.h"
#import "BbTextDescription.h"
#import "BbParseText.h"
#import "BbPatch.h"

@interface BbPatchViewController () 

@property (nonatomic,strong)            BbScrollView            *scrollView;
@property (nonatomic,strong)            BbPatch                 *patch;
@end

@implementation BbPatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self.view layoutIfNeeded];
    [self setupPatchView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.patch.view updateAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupScrollView
{
    self.scrollView = [[BbScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.scrollView];
    [self.view addConstraints:[self.scrollView pinEdgesToSuperWithInsets:UIEdgeInsetsZero]];
}

- (void)setPatchText:(NSString *)text
{
    BbPatchDescription *description = [BbParseText parseText:text];
    self.patch = [BbPatch objectWithDescription:description];
}

- (void)setupPatchView
{
    BbPatchView *patchView = (BbPatchView *)[self.patch loadView];
    patchView.scrollView = self.scrollView;
    patchView.backgroundColor = [UIColor whiteColor];
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
