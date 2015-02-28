//
//  PostOperation.h
//  SnapMe
//
//  Created by Werck Ayrton on 24/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATIC_TOKEN @"m198sOkJEn37DjqZ32lpRu76xmw288xSQ9"

@protocol PostRequestCompleted

-(void) didPostRequestFailed:(NSError *)error;
-(void) didPostRequestSucessed:(NSMutableData *)responseData;
-(void) didPostRequestGetDataSucessed:(NSMutableData *)responseData indexOfSnap:(NSInteger)indexOfSnap;

@end


@interface PostOperation : NSOperation  <NSURLConnectionDelegate>//Revoir protocol pour operation to be concurrent
{
    id <PostRequestCompleted> _delegate;
}

@property (strong) id myData;
@property (strong) NSString *token;
@property (strong) NSString *endPoint;
@property (nonatomic) NSInteger indexOfSnaps;
@property (strong) id delegate;
@property (strong, nonatomic) NSMutableData *responseData;

-(id)initWithData:(id)data;

@end
