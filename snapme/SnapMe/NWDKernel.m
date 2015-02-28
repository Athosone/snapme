//
//  NWDKernel.m
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "NWDKernel.h"

@implementation NWDKernel



- (id)init
{
    self = [super init];
    if (self)
    {
        //On peut considérer un operation queue comme un pool de thread
        self.operationQueue = [[NSOperationQueue alloc] init];
        //On definit le maximum de thread par pool (par default j'ai mis le max que apple accepte
        [self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return self;
}

@end
