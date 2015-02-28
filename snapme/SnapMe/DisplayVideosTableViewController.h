//
//  DisplayVideosTableViewController.h
//  SnapMe
//
//  Created by Werck Ayrton on 01/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

#import "NWDClient.h"

@interface DisplayVideosTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *medias;

@property (nonatomic, strong) NSMutableArray *listSentTimestamp;
@property (strong, nonatomic) NWDClient *client;
@property (strong, nonatomic) NSString *titleView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIToolbar     *toolBar;

@end
