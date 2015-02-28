//
//  SegmentManagingViewController.m
//  SnapMe
//
//  Created by Werck Ayrton on 01/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "SegmentManagingViewController.h"


@interface SegmentManagingViewController ()

@property (nonatomic, retain, readwrite) IBOutlet UISegmentedControl * segmentedControl;
@property (nonatomic, retain, readwrite) UIViewController            * activeViewController;
@property (nonatomic, retain, readwrite) NSArray                     * segmentedViewControllers;

- (void)didChangeSegmentControl:(UISegmentedControl *)control;
- (NSArray *)segmentedViewControllerContent;

@end

@implementation SegmentManagingViewController

@synthesize segmentedControl, activeViewController, segmentedViewControllers;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        // Further initialization if needed
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.segmentedViewControllers = [self segmentedViewControllerContent];
    
    NSArray * segmentTitles = @[@"Photos", @"Videos"];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTitles];
    self.segmentedControl.selectedSegmentIndex = 0;
    [self.segmentedControl addTarget:self
                              action:@selector(didChangeSegmentControl:)
                    forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    [self didChangeSegmentControl:self.segmentedControl]; // kick everything off
}

- (NSArray *)segmentedViewControllerContent {
    DisplayPhotosTableViewController * controller1 = [[DisplayPhotosTableViewController alloc] init];
    DisplayVideosTableViewController * controller2 = [[DisplayVideosTableViewController alloc] init];
    
    controller1.medias = self.photos;
    controller1.titleView = self.titleView;
    controller1.listSentTimestamp = self.listSentTimestamp;
    controller1.client = self.client;
    [self addChildViewController:controller1];
    
    controller2.medias = self.videos;
    controller2.listSentTimestamp = self.listSentTimestamp;
    [self addChildViewController:controller2];

    NSArray * controllers = [NSArray arrayWithObjects:controller1, controller2, nil];
    
    
    return controllers;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didChangeSegmentControl:(UISegmentedControl *)control {
    if (self.activeViewController) {
        //[self.activeViewController viewWillDisappear:NO];
        [self.activeViewController.view removeFromSuperview];
        [self.activeViewController viewDidDisappear:NO];
    }
    
    self.activeViewController = [self.segmentedViewControllers objectAtIndex:control.selectedSegmentIndex];
    
    //[self.activeViewController viewWillAppear:NO];
    [self.view addSubview:self.activeViewController.view];
    [self.activeViewController viewDidAppear:NO];
    
    //NSString * segmentTitle = [control titleForSegmentAtIndex:control.selectedSegmentIndex];
  //  self.navigationItem.backBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:segmentTitle style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController viewDidAppear:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController viewWillAppear:animated];
}


@end
