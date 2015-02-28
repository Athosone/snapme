//
//  ViewController.h
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SnapsTableViewController.h"
#import "PostOperation.h"


@interface LoginViewController : UIViewController <PostRequestCompleted>

//IVars
@property (strong, nonatomic) NWDClient *client;

//IBOutlet
@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *progdialog;

//IBAction
- (IBAction)connexionButton:(UIButton *)sender;

@end

