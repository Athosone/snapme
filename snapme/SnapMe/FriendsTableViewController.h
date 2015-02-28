//
//  FriendsTableViewController.h
//  SnapMe
//
//  Created by Romain Arsac on 16/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWDClient.h"

@interface FriendsTableViewController : UITableViewController

//iVars
@property (strong, nonatomic) NWDClient *client;

//IBOutlet
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;

@end
