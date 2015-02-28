//
//  DisplayPhotosTableViewController.h
//  Snapchat
//
//  Created by Werck Ayrton on 20/09/2014.
//  Copyright (c) 2014 Romain Arsac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWDClient.h"
#import <MediaPlayer/MediaPlayer.h>

@interface DisplayPhotosTableViewController : UITableViewController

//IVars
@property (nonatomic, strong) NSMutableArray *medias;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) NSMutableArray *listSentTimestamp;
@property (strong, nonatomic) NWDClient *client;
@property (strong, nonatomic) NSString *titleView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIToolbar     *toolBar;


@end
