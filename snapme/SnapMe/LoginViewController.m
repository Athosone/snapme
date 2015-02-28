//
//  ViewController.m
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.loginTextField.placeholder = @"Snapchat Login";
    self.passwordTextField.placeholder = @"Snapchat Password";
    self.progdialog.hidesWhenStopped = true;

    [self.loginTextField becomeFirstResponder];

    self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:255/255.0 green:146/255.0 blue:0/255.0 alpha:1.0];
//self.navigationController.navigationBar.barTintColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1.0];
    self.navigationController.navigationBar.translucent = YES;
    [[self navigationController] setNavigationBarHidden:YES animated:YES];

#warning a supprimer
    self.loginTextField.text = @"helloworldbis";
    self.passwordTextField.text = @"lolilol69";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connexionButton:(UIButton *)sender
{
    [self.progdialog startAnimating];
    self.loginButton.hidden = true;
    self.client = [[NWDClient alloc] init];
    [self.client login:self.loginTextField.text password:self.passwordTextField.text delegate:self];
}

-(void) didPostRequestFailed:(NSError *)error
{
    [self.progdialog stopAnimating];
    self.loginButton.hidden = false;
}

-(void) didPostRequestSucessed:(NSMutableData *)responseData
{
    NSArray         *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString        *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager   *manager = [NSFileManager defaultManager];
    NSString        *pathWithSender =
    [@"/" stringByAppendingString:[documentsDirectory stringByAppendingPathComponent:self.client.username]];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    
    [self.progdialog stopAnimating];
    self.loginButton.hidden = false;
    if ([[dict objectForKey:@"logged"] integerValue] == 1)
    {
        if (![manager fileExistsAtPath:pathWithSender])
        {
            NSError *error;
            if (![manager createDirectoryAtPath:pathWithSender withIntermediateDirectories:YES attributes:nil error:&error])
            {
                NSLog(@"Create directory error: %@", error);
            }
        }
        self.client.pathRoot = pathWithSender;
        NSLog(@"PathRoot: %@",pathWithSender);
        [[NSUserDefaults standardUserDefaults] setObject:pathWithSender forKey:@"pathToSnapMe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.client updateClientWithJSON:dict];
        AppDelegate *appDelegate= (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        appDelegate.client = self.client;
        [self performSegueWithIdentifier:@"loginSucess" sender:self];
    }
    else
    {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Connexion impossible"
                                                         message:@"Veuillez vérifier vos identifiants snapchat."
                                                        delegate:self
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles: nil];
        [alert show];
    }
   
}

-(void) didPostRequestGetDataSucessed:(NSMutableData *)responseData indexOfSnap:(NSInteger)indexOfSnap
{
  /*  NSData *mediaData = [[NSData alloc] init];
    BOOL isVideo = NO;
    NWDSnapMedia *snap = [self.client.snapMedias objectAtIndex:indexOfSnap];
    NSString *sender = snap.sender;
    NSString *id_snaps = snap.snapId;
    
    if ([NWDSnapMedia isMedia:responseData] == NO)
    {
//        NSLog(@"Media type: %ld", (long)snap.mediaType);
//        NSLog(@"Media status: %ld", (long)snap.mediaStatus);
//        NSLog(@"responseData %@", responseData);
        mediaData = [NWDRequest decrypt:responseData];
    }
    else
    {
        mediaData = responseData;
    }
    if (!mediaData)
    {
        NSLog(@"Le mediaDate est nul");
        return;
    }
    if (((const unsigned char *)mediaData.bytes)[0] == 0x00 || ((const unsigned char *)mediaData.bytes)[1] == 0x00)
        isVideo = YES;
    else
    {
        UIImage *image = [UIImage imageWithData:mediaData];
        [[self.client.snapMedias objectAtIndex:indexOfSnap] setValue:image forKey:@"mediaImage"];
       [NSNotificationCenter defaultCenter];
        NSNotification* notification = [NSNotification notificationWithName:@"receivedSnapsMedias" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
          //Async save of files
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *nameVideos = nil;
            NSString *documentsDirectory = self.client.pathRoot;//[paths objectAtIndex:0];
            NSFileManager   *manager = [NSFileManager defaultManager];
            NSString        *pathWithSender =
            [@"/" stringByAppendingString:[documentsDirectory stringByAppendingPathComponent:sender]];
            if (isVideo)
                nameVideos = [NSString stringWithFormat:@"/%@.mp4", id_snaps];
            else
                nameVideos = [NSString stringWithFormat:@"/%@.jpg", id_snaps];
            NSString *filePath = [pathWithSender stringByAppendingPathComponent:nameVideos];
            if (![manager fileExistsAtPath:pathWithSender])
            {
                NSError *error;
                if (![manager createDirectoryAtPath:pathWithSender withIntermediateDirectories:YES attributes:nil error:&error])
                {
                    NSLog(@"Create directory error: %@", error);
                }
            }
            if ([manager fileExistsAtPath:pathWithSender])
                {
                    NSLog(@"Directory exist");
                    if ([manager fileExistsAtPath:filePath])
                        NSLog(@"File already exist");
                    else
                    {
                        [mediaData writeToFile:filePath atomically:YES];
                        NSURL   *url = [NSURL fileURLWithPath:[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        if ((((const unsigned char *)mediaData.bytes)[0] == 0x00 || ((const unsigned char *)mediaData.bytes)[1] == 0x00) && url)
                        {
                            [[self.client.snapMedias objectAtIndex:indexOfSnap] setValue:url forKey:@"mediaVideo"];
                        }
                        else
                        {
                            UIImage *image = [UIImage imageWithData:mediaData];
                            [[self.client.snapMedias objectAtIndex:indexOfSnap] setValue:image forKey:@"mediaImage"];
                        }
                    }
                   [NSNotificationCenter defaultCenter];
                    NSNotification* notification = [NSNotification notificationWithName:@"receivedSnapsMedias" object:self];
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                }
            else
            {
                NSLog(@"File not saved ");
            }
        });*/
    }
@end
