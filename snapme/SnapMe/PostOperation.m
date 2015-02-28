//
//  PostOperation.m
//  SnapMe
//
//  Created by Werck Ayrton on 24/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "PostOperation.h"
#import "NWDRequest.h"


@implementation PostOperation

- (id)initWithData:(id)data {
    if (self = [super init])
        
        self.myData = data;
    
    return self;
}

- (BOOL) isConcurrent
{
    return YES;
}


-(void)start
{
  //  NSLog(@"Enter Start operation idSnaps: %ld", (long)self.indexOfSnaps);
    
    @try {

        NWDRequest *req = nil;
        
        if (self.token)
            req = [[NWDRequest alloc] initWithConfiguration:self.endPoint token:self.token data:self.myData];
        else
             req = [[NWDRequest alloc] initWithConfiguration:self.endPoint token:STATIC_TOKEN data:self.myData];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
        
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [connection start];
        // Do some work on myData and report the results.
    }
    //catch quoi ? lolilol
    @catch(...) {
        // Do not rethrow exceptions.
    }
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //NSLog(@"AppendData %@", data);
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
    //  NSLog(@"MWDKernel didFinishLoading: %@, %ld", connection, (long)self.indexOfSnaps);
    //NSLog(@"MWDKernel didFinishLoading: indexOfSnaps: %ld", (long)self.indexOfSnaps);
    
    if ([NSJSONSerialization JSONObjectWithData:self.responseData
                                        options:0
                                          error:nil] == nil)
    {
        NSLog(@"Je suis la");
        [self.delegate didPostRequestGetDataSucessed:self.responseData indexOfSnap:self.indexOfSnaps];
    }
    else
    {
        [self.delegate didPostRequestSucessed:self.responseData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"NWDKernel didFailWithError: %@", error);
    [self.delegate didPostRequestFailed:error];
}


@end
