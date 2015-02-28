//
//  NWDClient.h
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "NWDKernel.h"
#import "NWDSnapMedia.h"
#import "NWDFriend.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface NWDClient : NWDKernel

//IVars
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *birthday;
@property (nonatomic) NSInteger *score;
@property (nonatomic) NSInteger *sent;
@property (nonatomic) NSInteger *received;
@property (nonatomic) NSInteger numberOfSnapsToDL;
@property (nonatomic, strong) NSMutableArray *snapMedias;
@property (nonatomic, strong) NSMutableArray *listSender;
@property (nonatomic, strong) NSMutableArray *listSnapsTodl;
@property (strong, nonatomic) NSString *pathRoot;
@property (strong, nonatomic) NSMutableArray *friends;


-(void) login:(NSString *)username password:(NSString *)password delegate:(id)delegate;
-(void) updateClientWithJSON:(NSDictionary *) jsonResult;
-(void) parseSnap:(NSDictionary *)jsonResult;
-(void) update:(id)delegate;
-(void) getSnaps:(id)delegate;
-(void) setSnapsToDL:(NSDictionary*)jsonResult;
-(NSString*) convertObjectToJson:(NSObject*) object;
-(NSString*)serializeSnapsMedias;
-(void)serializeSnapsMediasAtPath:(NSString *)filePath;

@end