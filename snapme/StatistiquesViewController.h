//
//  StatistiquesViewController.h
//  SnapMe
//
//  Created by Romain Arsac on 14/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWDClient.h"

@interface StatistiquesViewController : UIViewController

//iVars
@property (strong, nonatomic) NWDClient *client;


//IBOutlets
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuBarButtonItem;



@end
