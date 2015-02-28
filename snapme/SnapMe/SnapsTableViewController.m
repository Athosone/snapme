//
//  SnapsTableViewController.m
//  SnapMe
//
//  Created by Romain Arsac on 23/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "SnapsTableViewController.h"
#import "DisplayPhotosTableViewController.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"


@interface SnapsTableViewController ()

@end

@implementation SnapsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;

    AppDelegate *appDelegate= (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.client = appDelegate.client;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSnapsMedias:) name:@"receivedSnapsMedias" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"reloadTableView" object:nil];

    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background_empty.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //[UIColor colorWithPatternImage:image];self.navigationController.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];
    self.tableView.opaque = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.menuBarButtonItem.target = self.revealViewController;
    self.menuBarButtonItem.action = @selector(revealToggle:);

    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor orangeColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateSnaps)
                  forControlEvents:UIControlEventValueChanged];


}

- (void) updateSnaps
{
    [self.client update:self];
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }

}

// Wesh ma gueule ca craint du boudin

-(void) reloadTableView
{
    NSString *pathRoot = [[NSUserDefaults standardUserDefaults] stringForKey:@"pathToSnapMe"];
    NSString *filePath = [pathRoot stringByAppendingString:[@"/" stringByAppendingString:@"SnapMedias.json"]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self.client serializeSnapsMediasAtPath:filePath];
    
}

- (void) receivedSnapsMedias:(NSNotification*)notificaiton
{
    //Serialize
   //petit bug
    int i = [[[notificaiton userInfo] objectForKey:@"indexOfSnap"] intValue];
    NSLog(@"I: %d\n self.client:%d", (int)i, (int)self.client.numberOfSnapsToDL);
    if (i == self.client.numberOfSnapsToDL - 2)
    {
        [self reloadTableView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.client.listSender.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // Configure the cell...
    cell.textLabel.text = [self.client.listSender objectAtIndex:indexPath.row];
    cell.detailTextLabel.numberOfLines = 1;

    for (NWDSnapMedia *item in self.client.snapMedias)
    {
        if ([item.sender isEqual:cell.textLabel.text])
        {
            NSLog(@"Photo %@", item.sender);
            if (item.mediaImage)
            {
                UIImageView *image = [[UIImageView alloc]initWithImage:item.mediaImage];
                cell.imageView.image = image.image;
            }
            else if (item.mediaVideo)
            {
                NSURL *url = [item mediaVideo];
                AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
                generate1.appliesPreferredTrackTransform = YES;
                NSError *err = NULL;
                CMTime time = CMTimeMake(1, 2);
                CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *image = [[UIImage alloc] initWithCGImage:oneRef];
                
                cell.imageView.image = image;
            }
            else
            {
               cell.imageView.image = [UIImage imageNamed: @"logo_login.png"];
            }
            float timestamp = [item.sentTimestamp longLongValue];
          //  NSLog(@"TIMESTAMP OK: %ld", (long)item.sentTimestamp);
            cell.detailTextLabel.text = [NWDSnapMedia getDate:timestamp];
            // Pour agrandir l'image
            CGSize itemSize = CGSizeMake(80, 80);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [cell.imageView.image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            //cell.textLabel.backgroundColor = [UIColor clearColor];
            //cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor colorWithWhite:1 alpha:.0];
            cell.imageView.layer.cornerRadius = 45/2;
            cell.imageView.clipsToBounds = YES;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosureIndicator.png"]];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Cell text: %@", cell.textLabel.text);
    NSMutableArray  *photos = [[NSMutableArray alloc] init];
    NSMutableArray  *videos = [[NSMutableArray alloc] init];
    NSMutableArray *listSentTimestamp = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.client.snapMedias.count; ++i)
    {
        NWDSnapMedia *a = [self.client.snapMedias objectAtIndex:i];
        if (a && a.sender && [a.sender length] > 0 && (a.mediaImage || a.mediaVideo) && [a.sender isEqual:cell.textLabel.text])
        {
            if (a.mediaVideo)
            {
                [videos addObject:[[self.client.snapMedias objectAtIndex:i] mediaVideo]];
                [listSentTimestamp addObject:[[self.client.snapMedias objectAtIndex:i] sentTimestamp]];
                //NSLog(@"Video path: %@", [[[self.client.snapMedias objectAtIndex:i] mediaVideo] path]);
            }
            else
            {
            [photos addObject:[[self.client.snapMedias objectAtIndex:i] mediaImage]];
                [listSentTimestamp addObject:[[self.client.snapMedias objectAtIndex:i] sentTimestamp]];
            }
        }
    }
    SegmentManagingViewController *cvc = [[SegmentManagingViewController alloc] init];
    cvc.photos = photos;
    cvc.videos = videos;
    NSLog(@"LoadView %lu", (unsigned long)cvc.videos.count);
    cvc.listSentTimestamp = listSentTimestamp;
    cvc.client = self.client;
    [self.navigationController pushViewController:cvc animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}


- (CGFloat)tableView:(UITableView *)tableView widthForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}


-(void) didPostRequestFailed:(NSError *)error
{
    NSLog(@"request failed");

}

-(void) didPostRequestSucessed:(NSMutableData *)responseData
{
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    
    
    NSLog(@"request sucessed");
    NSLog(@"%@", dict);
    dict = [dict objectForKey:@"updates_response"];
    [self.client updateClientWithJSON:dict];
}

-(void) didPostRequestGetDataSucessed:(NSMutableData *)responseData indexOfSnap:(NSInteger)indexOfSnap
{
    NSLog(@"data sucessed");
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
