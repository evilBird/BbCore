//
//  ViewController.m
//  BbCoreProject
//
//  Created by Travis Henspeter on 1/14/16.
//  Copyright © 2016 birdSound. All rights reserved.
//

#import "ViewController.h"
#import "BbPatchViewController.h"

#import "BbAdd.h"
#import "BbInstance.h"
#import "BbClass.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testAddObject];
    [self testInstanceObject];
    [self testClassObject];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)testAddObject
{
    BbAdd *add = [[BbAdd alloc]initWithArguments:@"5"];
    [add.inlets[0] setInputElement:@(4)];
    id output = [[add outlets][0] outputElement];
    NSAssert(nil!=output, @"ADD TEST FAILED");
}

- (void)testInstanceObject
{
    BbInstance *instance = [[BbInstance alloc]initWithArguments:@"NSMutableArray"];
    [instance loadBang];
    [instance.inlets[0] setInputElement:@[@"addObject:",@(5)]];
    [instance.inlets[0] setInputElement:@[@"addObject:",@(10)]];
    id output = nil;
    [instance.inlets[0] setInputElement:@[@"objectAtIndex:",@(0)]];
    output = [instance.outlets[0] outputElement];
    NSAssert(nil!=output,@"INSTANCE TEST FAILED");
    output = nil;
    [instance.inlets[0] setInputElement:@[@"objectAtIndex:",@(1)]];
    output = [instance.outlets[0] outputElement];
    NSAssert(nil!=output, @"INSTANCE TEST FAILED");
    
}

- (void)testClassObject
{
    BbClass *myClass = [[BbClass alloc]initWithArguments:@"NSMutableArray"];
    id output = nil;
    [myClass.inlets[0] setInputElement:@"new"];
    output = [myClass.outlets[0] outputElement];
    NSAssert(nil!=output, @"CLASS TEST FAILED");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    return;
    
    BbPatchViewController *patchViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BbPatchViewControllerID"];
    NSString *patchTitle = @"TestPatchDescription 3A";
    NSString *patchPath = [[NSBundle mainBundle]pathForResource:patchTitle ofType:@"txt"];
    NSString *patchText = [NSString stringWithContentsOfFile:patchPath encoding:1 error:nil];
    [self presentViewController:patchViewController animated:YES completion:^{
        [patchViewController setPatch:patchTitle withText:patchText completion:^{
            NSLog(@"finished loading patch!");
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
