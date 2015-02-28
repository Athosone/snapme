//
//  NWDKernel.h
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWDRequest.h"

@interface NWDKernel : NSObject

@property (strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) id delegate;
@property (strong, nonatomic) NSMutableData *responseData;

@end
