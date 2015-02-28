//
//  NWDRequest.h
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NWDRequest : NSMutableURLRequest

+ (NSString *)timestampString;
+ (NSString *)encodeQueryParam:(NSString *)param;
+ (NSString *)encodeQuery:(NSDictionary *)dict;
+ (NSData *)decrypt:(NSData *)data;
- (id)initWithConfiguration:(NSString *)endpoint
                      token:(NSString *)token
                      data:(NSMutableDictionary *)data;

@end
