//
//  DisplayVideosTableViewController.m
//  SnapMe
//
//  Created by Werck Ayrton on 01/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "DisplayVideosTableViewController.h"
#import "ViewMediaViewController.h"

@interface DisplayVideosTableViewController ()

@end

@implementation DisplayVideosTableViewController


- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"displayVideosStoryBoard"];
    if (self != nil)
    {
        // Further initialization if needed
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"ViewVideo did load %lu", (unsigned long)self.medias.count);
    
    //TEST 64 for nav controller
#warning Ya du bug a laffichage...
   self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    //Sale je pense qu'il faudrait que ce soit gérer dans le segmentmanagingViewController
    UIBarButtonItem *buttonEditRows = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(buttonEditRows:)];
    self.navigationController.topViewController.navigationItem.rightBarButtonItem = buttonEditRows;
    [self.tableView setAllowsMultipleSelectionDuringEditing:YES];
    
    
    CGRect frameForToolBar = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 44 - 64, [[UIScreen mainScreen] bounds].size.width, 44);
    self.toolBar = [[UIToolbar alloc] initWithFrame:frameForToolBar];
    //self.toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(buttonCancelSavePressed:)];
    UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(boutonSavePressed:)];
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:cancelButton];
    [items addObject:buttonSave];
    
    [self.toolBar setItems:items animated:NO];
    self.toolBar.hidden = YES;
    
    [self.view addSubview:self.toolBar];
}

- (IBAction)buttonCancelSavePressed:(id)sender
{
    [self.tableView setEditing:NO animated:NO];
    self.toolBar.hidden = YES;
}

- (IBAction)buttonEditRows:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    self.toolBar.hidden = NO;
}

- (IBAction)boutonSavePressed:(id)sender
{
    int i = 0;
    NSArray *indexPathArray = [self.tableView indexPathsForSelectedRows];
    for(NSIndexPath *indexPath in indexPathArray)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if([cell isEditing] && [cell isSelected])
        {
            NSURL *url = [self.medias objectAtIndex:indexPath.row];
            if (url)
            {
                UISaveVideoAtPathToSavedPhotosAlbum([url absoluteString], nil, nil, nil);
                i++;
            }
        }
    }
    NSLog(@"Videos saved: %d", i);
    if (i > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Videos successfully saved"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    [self.tableView setEditing:NO animated:NO];
    self.toolBar.hidden = YES;
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
    NSLog(@"Elements");//, self.medias.count);
    return self.medias.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self.medias objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NWDSnapMedia getDate:[[self.listSentTimestamp objectAtIndex:indexPath.row] floatValue]];
    
    NSLog(@"NSURL For Video: %@", [url absoluteURL]);
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *image = [[UIImage alloc] initWithCGImage:oneRef];
    
    cell.imageView.image = image;
    // Pour agrandir l'image
    CGSize itemSize = CGSizeMake(60, 60);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView isEditing] == NO)
    {
        ViewMediaViewController *vm = [[ViewMediaViewController alloc] initWithUrl:[self.medias objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:vm animated:YES];
    }
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
