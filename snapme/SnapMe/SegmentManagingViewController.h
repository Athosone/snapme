//
//  SegmentManagingViewController.h
//  SnapMe
//
//  Created by Werck Ayrton on 01/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayPhotosTableViewController.h"
#import "DisplayVideosTableViewController.h"

@interface SegmentManagingViewController : UIViewController<UINavigationControllerDelegate>
{
    UISegmentedControl    * segmentedControl;
    UIViewController      * activeViewController;
    NSArray               * segmentedViewControllers;
}

@property (nonatomic, retain, readonly) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain, readonly) UIViewController            *activeViewController;
@property (nonatomic, retain, readonly) NSArray                     *segmentedViewControllers;

//DisplayPhotosTableViewController
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) NSMutableArray *stories;
@property (nonatomic, strong) NSMutableArray *listSentTimestamp;
@property (strong, nonatomic) NWDClient *client;
@property (strong, nonatomic) NSString *titleView;


@end
