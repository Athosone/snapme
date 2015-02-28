//
//  ViewMediaViewController.h
//  SnapMe
//
//  Created by Werck Ayrton on 19/11/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewMediaViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageViewMedia;
@property (strong, nonatomic) UIImage               *image;
@property (strong, nonatomic) NSURL               *videoUrl;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property  (strong, nonatomic) NSURL *url;

-(id) initWithImage:(UIImage*)image;
-(id) initWithUrl:(NSURL*)url;


@end
