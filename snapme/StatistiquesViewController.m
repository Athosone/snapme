//
//  StatistiquesViewController.m
//  SnapMe
//
//  Created by Romain Arsac on 14/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "StatistiquesViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface StatistiquesViewController ()

@end

@implementation StatistiquesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *appDelegate= (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.client = appDelegate.client;

    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.menuBarButtonItem.target = self.revealViewController;
    self.menuBarButtonItem.action = @selector(revealToggle:);

    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
