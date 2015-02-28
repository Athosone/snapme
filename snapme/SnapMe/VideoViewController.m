//
//  VideoViewController.m
//  SnapMe
//
//  Created by Werck Ayrton on 01/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "VideoViewController.h"

@interface VideoViewController ()
@property (nonatomic, strong, readwrite) MPMoviePlayerController *moviePlayer;
@end

@implementation VideoViewController

@synthesize moviePlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.moviePlayer play];
    // Do any additional setup after loading the view.
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
