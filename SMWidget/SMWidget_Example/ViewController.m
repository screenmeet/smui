//
//  ViewController.m
//  SMWidget_Example
//
//  Created by Adrian Cayaco on 07/09/2016.
//  Copyright © 2016 Screenmeet. All rights reserved.
//

#import "ViewController.h"
#import "SMWidgetManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[SMWidgetManager sharedManager] initializeSMWidget];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
