//
//  WriteOnDiskOperation.h
//  SnapMe
//
//  Created by Werck Ayrton on 15/10/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWDClient.h"


@interface WriteOnDiskOperation : NSOperation
{
    BOOL        executing;
    BOOL        finished;
}
@property (strong, nonatomic) NWDClient *client;
@property (strong, nonatomic) NSString *filePath;
- (void)completeOperation;

@end
