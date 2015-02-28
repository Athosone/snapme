//
//  WriteOnDiskOperation.m
//  SnapMe
//
//  Created by Werck Ayrton on 15/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "WriteOnDiskOperation.h"

@implementation WriteOnDiskOperation

- (id)init {
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}


- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @try
    {
        NSMutableString *result = [[NSMutableString alloc] init];
        
        [result appendString:[self.client serializeSnapsMedias]];
        [result writeToFile:self.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [self completeOperation];
    }
    @catch(...)
    {
        // Do not rethrow exceptions.
    }
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
