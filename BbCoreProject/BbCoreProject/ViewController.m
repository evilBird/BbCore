//
//  ViewController.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/14/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id patchViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BbPatchViewControllerID"];
    NSString *patchPath = [[NSBundle mainBundle]pathForResource:@"TestPatchDescription 3A" ofType:@"txt"];
    NSString *patchText = [NSString stringWithContentsOfFile:patchPath encoding:1 error:nil];
    [self presentViewController:patchViewController animated:YES completion:^{
        [patchViewController setValue:patchText forKey:@"patchText"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
