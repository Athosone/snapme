//
//  NWDClient.m
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "NWDClient.h"
#import "PostOperation.h"
#import "WriteOnDiskOperation.h"

@implementation NWDClient

-(NSString*) convertObjectToJson:(NSObject*) object
{
    NSError *writeError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&writeError];
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (writeError)
        NSLog(@"Error when serialization: %@", writeError);
    else
        NSLog(@"serialization: %@", result);
    return result;
}

-(void) login:(NSString *)username password:(NSString *)password delegate:(id)delegate
{
    super.delegate = delegate;
    self.username = username;
    self.snapMedias = [[NSMutableArray alloc] init];
    self.listSender = [[NSMutableArray alloc] init];
    self.friends = [[NSMutableArray alloc] init];
    
    // self.score = 0;
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    data[@"username"] = username;
    data[@"password"] = password;
    
    PostOperation *op = [[PostOperation alloc]initWithData:data];
    op.delegate = self.delegate;
    op.endPoint = @"/bq/login";
    op.myData = data;
    [self.operationQueue addOperation:op];
}

-(void) updateClientWithJSON:(NSDictionary *) jsonResult
{
    NSLog(@"%@", jsonResult);
    
    self.authToken = [jsonResult objectForKey:@"auth_token"];
    self.email = [jsonResult objectForKey:@"email"];
    self.birthday = [jsonResult objectForKey:@"birthday"];
    [self setSnapsToDL:jsonResult];
    
    [self parseSnap:jsonResult];
    [self parseFriend:jsonResult];
}

//Agerer : JPG mp4 et autre format peut etre async ?
-(void) setSnapsToDL:(NSDictionary *)jsonResult
{
    NSDictionary    *snapJson = [jsonResult objectForKey:@"snaps"];
    NSFileManager   *manager = [NSFileManager defaultManager];
    self.listSnapsTodl = [[NSMutableArray alloc] init];
    for (id snaps in snapJson)
    {
        NSString    *idSnaps = [snaps objectForKey:@"id"];
        NSString    *sender = [snaps objectForKey:@"sn"];
        NSString    *pathWithSender =
        [@"/" stringByAppendingString:[self.pathRoot stringByAppendingPathComponent:sender]];
        NSInteger   mediaType = [[snaps objectForKey:@"m"] integerValue];
        
        
        if ([snaps objectForKey:@"sn"] && [[snaps objectForKey:@"st"] integerValue] == 1 && ([[snaps objectForKey:@"m"] integerValue] >= 0 && [[snaps objectForKey:@"m"] integerValue] <= 2))
        {
            if (self.listSender.count != 0 && sender)
            {
                if (![self.listSender containsObject:sender])
                    [self.listSender addObject:sender];
            }
            else if (self.listSender.count == 0 && sender)
                [self.listSender addObject:sender];
            
            if ([manager fileExistsAtPath:pathWithSender])
            {
                NSString        *filePath = nil;
                if (mediaType == 0)
                    filePath = [@"/" stringByAppendingString:[pathWithSender stringByAppendingPathComponent:[idSnaps stringByAppendingString:@".jpg"]]];
                else
                    filePath = [@"/" stringByAppendingString:[pathWithSender stringByAppendingPathComponent:[idSnaps stringByAppendingString:@".mp4"]]];
                if (![manager fileExistsAtPath:filePath])
                {
                    NSLog(@"Snaps with id: %@ added with sender: %@", idSnaps, [snaps objectForKey:@"sn"]);
                    [self.listSnapsTodl addObject:idSnaps];
                }
            }
            else
            {
                NSLog(@"Snaps with id: %@ added with sender: %@", idSnaps, [snaps objectForKey:@"sn"]);
                [self.listSnapsTodl addObject:idSnaps];
            }
        }
    }
    self.numberOfSnapsToDL = self.listSnapsTodl.count;
    NSLog(@"Number of snaps to dl: %lul", (unsigned long)[self.listSnapsTodl count]);
}

-(void) parseFriend:(NSDictionary *)jsonResult
{
    NSDictionary *friendsJson = [jsonResult objectForKey:@"friends"];
    
    if (friendsJson)
    {
        for (id friend in friendsJson)
        {
            NWDFriend *tmp = [[NWDFriend alloc] init];
            
            tmp.name = [friend objectForKey:@"name"];
            tmp.displayName = [friend objectForKey:@"display"];
            [self.friends addObject:tmp];
        }
    }
}

// Va falloir la rendre plus jolie celle-ci
-(void) parseSnap:(NSDictionary *)jsonResult
{
    NSDictionary *snapJson = [jsonResult objectForKey:@"snaps"];
    NSLog(@"Enter parsesnap");
    if (snapJson)
    {
        for (id snaps in snapJson)
        {
            if ([self.listSnapsTodl containsObject:[snaps objectForKey:@"id"]])
            { //If it is a image
                if ([snaps objectForKey:@"sn"] && [[snaps objectForKey:@"st"] integerValue] == 1 && [[snaps objectForKey:@"m"] integerValue] == 0)
                {
                    NWDSnapMedia *tmp = [[NWDSnapMedia alloc] init];
                    
                    tmp.snapId = [snaps objectForKey:@"id"];
                    tmp.sender = [snaps objectForKey:@"sn"];
                    tmp.recipient = [snaps objectForKey:@"rp"];
                    tmp.lastInteractionTimestamp = [snaps objectForKey:@"ts"];
                    tmp.sentTimestamp = [snaps objectForKey:@"sts"];
                    tmp.mediaType = [[snaps objectForKey:@"m"] integerValue];
                    tmp.mediaStatus = [[snaps objectForKey:@"st"] integerValue];
                    tmp.timer = [[snaps objectForKey:@"t"] integerValue];
                    [self.snapMedias addObject:tmp];
                }
                // If is a video with audio (1) and no audio (2)
                else if ([snaps objectForKey:@"sn"] && [[snaps objectForKey:@"st"] integerValue] == 1 && ([[snaps objectForKey:@"m"] integerValue] == 1 || [[snaps objectForKey:@"m"] integerValue] == 2))
                {
                    //NSLog(@"Bonjour je suis une video lolilol");
                    NWDSnapMedia *tmp = [[NWDSnapMedia alloc] init];
                    
                    tmp.snapId = [snaps objectForKey:@"id"];
                    tmp.sender = [snaps objectForKey:@"sn"];
                    tmp.recipient = [snaps objectForKey:@"rp"];
                    tmp.lastInteractionTimestamp = [snaps objectForKey:@"ts"];
                    tmp.sentTimestamp = [snaps objectForKey:@"sts"];
                    tmp.mediaType = [[snaps objectForKey:@"m"] integerValue];
                    tmp.mediaStatus = [[snaps objectForKey:@"st"] integerValue];
                    tmp.timer = [[snaps objectForKey:@"t"] integerValue];
                    [self.snapMedias addObject:tmp];
                }
            }
        }
    }
    NSLog(@"listSender : %@", self.listSender);
    NSLog(@"SnapMedias : %lu", (unsigned long)[self.listSnapsTodl count]);
    [self getSnaps:nil];
}

- (void) getSnaps:(id)delegate
{
    for (int i = 0;(i < [self.listSnapsTodl count]); ++i)
    {
        NSLog(@"GETSNAP I:%d", i);
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        if (data)
        {
            data[@"id"] = [[self.snapMedias objectAtIndex:i] snapId];
            data[@"username"] = self.username;
            NWDRequest             *request = [[NWDRequest alloc] initWithConfiguration:@"/bq/blob" token:self.authToken data:data];
            AFHTTPRequestOperation *afOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            afOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/octet-stream"];
            [afOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 NSData *response = (NSData*)responseObject;
                 NSLog(@"Response from GetSnaps: %@", response);
                 [self didReceivedData:response indexOfSnaps:i];
             }failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 NSLog(@"Response from GetSnaps ERROR: %@", [error localizedDescription]);
             }];
            [self.operationQueue addOperation:afOperation];
        }
    }
    
    NSBlockOperation    *op = [[NSBlockOperation alloc] init];
    [op addExecutionBlock:^{
        NSMutableArray *snaps = [NWDSnapMedia deserialize:@"SnapMedias.json"];
        if (snaps)
        {
            [self.snapMedias addObjectsFromArray:snaps];
            for (int i = 0; i < [self.snapMedias count]; ++i)
            {
                NWDSnapMedia *tmp = [self.snapMedias objectAtIndex:i];
                NSString *pathRoot = [[NSUserDefaults standardUserDefaults] stringForKey:@"pathToSnapMe"];
                NSString *sender = tmp.sender;
                NSString *fileName = tmp.snapId;
#warning pour l'instant enregistrement que photo vu bug serialization apres voir pour mpg ou mpeg ?
                //                if (tmp.mediaType == 0)
                //                {
                //                   tmp.mediaImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.jpg", pathRoot, sender, fileName]];
                //                }
                //                else if (tmp.mediaType == 1 || tmp.mediaType == 2)
                //                {
                //                   tmp.mediaImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.mpg", pathRoot, sender, fileName]];
                //                }
                tmp.mediaImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.jpg", pathRoot, sender, fileName]];
            }
            [NSNotificationCenter defaultCenter];
            NSNotification* notification = [NSNotification notificationWithName:@"reloadTableView" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    }];
    [self.operationQueue addOperation:op];
}


- (void) didReceivedData:(NSData*) responseData indexOfSnaps:(int)indexOfSnap
{
    NSData *mediaData = [[NSData alloc] init];
    BOOL isVideo = NO;
    NWDSnapMedia *snap = [self.snapMedias objectAtIndex:indexOfSnap];
   
    if ([NWDSnapMedia isMedia:responseData] == NO)
    {
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
        [[self.snapMedias objectAtIndex:indexOfSnap] setValue:image forKey:@"mediaImage"];
      /*  [NSNotificationCenter defaultCenter];
        NSNotification* notification = [NSNotification notificationWithName:@"receivedSnapsMedias" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:notification];*/
    }
    [self saveFile:isVideo mediaData:mediaData indexOfSnap:indexOfSnap];
}

//Async save of files
- (void) saveFile:(BOOL)isVideo mediaData:(NSData*)mediaData indexOfSnap:(int)indexOfSnap
{
    NWDSnapMedia *snap = [self.snapMedias objectAtIndex:indexOfSnap];
    NSString *sender = snap.sender;
    NSString *id_snaps = snap.snapId;
    NSDictionary *index = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:indexOfSnap], @"indexOfSnap", nil];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *nameMedia = nil;
        NSString *documentsDirectory = self.pathRoot;//[paths objectAtIndex:0];
        NSFileManager   *manager = [NSFileManager defaultManager];
        NSString        *pathWithSender =
        [@"/" stringByAppendingString:[documentsDirectory stringByAppendingPathComponent:sender]];
        if (isVideo)
            nameMedia = [NSString stringWithFormat:@"/%@.mp4", id_snaps];
        else
            nameMedia = [NSString stringWithFormat:@"/%@.jpg", id_snaps];
        NSString *filePath = [pathWithSender stringByAppendingPathComponent:nameMedia];
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
                    [[self.snapMedias objectAtIndex:indexOfSnap] setValue:url forKey:@"mediaVideo"];
                }
                else
                {
                    UIImage *image = [UIImage imageWithData:mediaData];
                    [[self.snapMedias objectAtIndex:indexOfSnap] setValue:image forKey:@"mediaImage"];
                }
            }
            NSNotification* notification = [NSNotification notificationWithName:@"receivedSnapsMedias" object:self userInfo:index];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        else
        {
            NSLog(@"File not saved ");
        }
    });
}

-(NSString*)serializeSnapsMedias
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result appendString:@"{\n"];
    [result appendString:@"\"NWDSnapMedia\":["];
    for (int i = 0; i < [self.snapMedias count]; ++i)
    {
        [result appendString:[[self.snapMedias objectAtIndex:i] serialize]];
        if (i < [self.snapMedias count] - 1)
            [result appendString:@","];
    }
    [result appendString:@"\n]\n}"];
    return result;
}

-(void)serializeSnapsMediasAtPath:(NSString *)filePath
{
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    
    [op addExecutionBlock:^{
        NSMutableString *result = [[NSMutableString alloc] init];
        
        [result appendString:[self serializeSnapsMedias]];
        [result writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }];
    
    [self.operationQueue addOperation:op];
}

//Methode a finir car incomplete
- (void) update:(id)delegate
{
    self.delegate = delegate;
    if (self.authToken)
    {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        data[@"username"] = self.username;
        PostOperation *op = [[PostOperation alloc]initWithData:data];
        op.delegate = self.delegate;
        op.endPoint = @"/bq/all_updates";
        op.token = self.authToken;
        [self.operationQueue addOperation:op];
    }
}

@end
