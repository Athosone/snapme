//
//  AppDelegate.h
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWDClient.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NWDClient *client;

@end

