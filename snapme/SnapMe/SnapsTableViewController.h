//
//  SnapsTableViewController.h
//  SnapMe
//
//  Created by Romain Arsac on 23/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "NWDClient.h"
#import "SegmentManagingViewController.h"
#import "PostOperation.h"

@interface SnapsTableViewController : UITableViewController <PostRequestCompleted>

@property (strong, nonatomic) IBOutlet UIView *contentVC;
@property (strong, nonatomic) NWDClient *client;
@property (strong, nonatomic) UIPopoverController *popoverMedias;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;
@end
