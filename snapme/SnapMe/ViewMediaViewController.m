//
//  ViewMediaViewController.m
//  SnapMe
//
//  Created by Werck Ayrton on 19/11/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "ViewMediaViewController.h"

@implementation ViewMediaViewController


-(id) initWithImage:(UIImage*)image
{
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewMediaController"];
    
    if (self)
        self.image = image;
    
    return self;
}

-(id) initWithUrl:(NSURL*)url
{
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"viewMediaController"];
    
    if (self)
        self.url = url;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.image)
    {
        self.imageViewMedia.image = self.image;
        self.imageViewMedia.hidden = NO;
    }
    if (self.url)
    {
        self.imageViewMedia.hidden = YES;
        self.moviePlayer = [[MPMoviePlayerController alloc] init];
        [self.moviePlayer setContentURL:self.url];
        // NSLog(@"Playing videos : %@", [self.moviePlayer contentURL]);
        // NSLog(@"Playing videos : %@", [[self.moviePlayer contentURL] absoluteString]);
        
        [self.moviePlayer.view setFrame:self.view.bounds];
        [self.moviePlayer setFullscreen:YES animated:YES];
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer play];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
