//
//  NWDSnapMedia.h
//  SnapMe
//
//  Created by Romain Arsac on 23/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NWDSnapMedia : NSObject

@property (nonatomic, strong) NSString *snapId;
@property (nonatomic, strong) NSString *sender;
@property (nonatomic, strong) NSString *recipient;
@property (nonatomic, strong) NSString *lastInteractionTimestamp;
@property (nonatomic, strong) NSString *sentTimestamp;
@property (nonatomic) NSInteger mediaType;
@property (nonatomic) NSInteger mediaStatus;
@property (nonatomic) NSInteger timer;
@property (nonatomic, strong) UIImage *mediaImage;
@property (nonatomic, strong) NSURL *mediaVideo;

//@property (nonatomic, strong) UIVide

+ (NSString *) getDate:(float)timestamp;
+ (BOOL) isMedia:(NSData *)data;
-(NSString*)serialize;
-(NSString*)serialize:(NSString*)fileName;
+(NSMutableArray*)deserialize:(NSString*)fileName;


@end
