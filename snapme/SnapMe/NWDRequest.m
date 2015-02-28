//
//  NWDRequest.m
//  SnapMe
//
//  Created by Romain Arsac on 22/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "NWDRequest.h"

#define PATTERN @"0001110111101110001111010101111011010001001110011000110001000110"
#define SECRET @"iEk21fuwZApXlz93750dmW22pw389dPwOk"
#define BLOB_ENC @"M02cnQ51Ji97vwT4"
#define USER_AGENT @"Snapchat/4.1.01 (Nexus 4; Android 18; gzip)"
#define URL @"https://feelinsonice-hrd.appspot.com"

@implementation NWDRequest

+ (NSData *)decrypt:(NSData *)data
{
    NSData * result = nil;

    unsigned char cKey[16];
    bzero(cKey, sizeof(cKey));
    [[BLOB_ENC dataUsingEncoding:NSASCIIStringEncoding] getBytes:cKey length:16];

    size_t bufferSize = [data length];
    void * buffer = malloc(bufferSize);

    size_t decryptedSize = 0;
    if (data)
    {
        //NSLog(@"%@", data);
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionECBMode, cKey, 16, NULL, [data bytes], [data length], buffer, bufferSize, &decryptedSize);
        
        if (cryptStatus == kCCSuccess) {
            result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
        } else {
            free(buffer);
            NSLog(@"DEC FAILED! CCCryptoStatus: %d", cryptStatus);
        }
    }


    return result;
}

+ (NSString *) sha256:(NSString *)clear
{
    const char *s=[clear cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];

    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, (unsigned int)keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

+ (NSString *) hash:(NSString *)first second:(NSString *)second
{
    first = [SECRET stringByAppendingString:first];
    second = [second stringByAppendingString:SECRET];

    NSString *hash1 = [self sha256:first];
    NSString *hash2 = [self sha256:second];

    NSMutableString *result = [[NSMutableString alloc] init];

    for (int i = 0; i < PATTERN.length; i++) {
        unichar c = [PATTERN characterAtIndex:i];
        if (c == '0') {
            [result appendString:[hash1 substringWithRange:NSMakeRange(i, 1)]];
        } else {
            [result appendString:[hash2 substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return result;
}

+ (NSString *) timestampString
{
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    return [NSString stringWithFormat:@"%llu", (unsigned long long)round(time * 1000.0)];
}

+ (NSString *) encodeQueryParam:(NSString *)param {
    NSMutableString * str = [NSMutableString string];
    for (NSInteger i = 0; i < param.length; i++) {
        unichar aChar = [param characterAtIndex:i];
        if (isalnum(aChar)) {
            [str appendFormat:@"%C", aChar];
        } else {
            [str appendFormat:@"%%%02X", (unsigned char)aChar];
        }
    }
    return str;
}

+ (NSString *) encodeQuery:(NSDictionary *)dict {
    NSMutableString * str = [NSMutableString string];

    for (NSString * key in dict) {
        if (str.length) [str appendString:@"&"];
        [str appendFormat:@"%@=%@", [self encodeQueryParam:key],
         [self encodeQueryParam:[dict[key] description]]];
    }

    return str;
}

- (id) initWithConfiguration:(NSString *)endpoint
                      token:(NSString *)token
                       data:(NSMutableDictionary *)data
{
    if ((self = [super init]))
    {
        [self setURL:[NSURL URLWithString:[URL stringByAppendingString:endpoint]]];
        [self setHTTPMethod:@"POST"];

        NSString *timestamp = self.class.timestampString;
        data[@"timestamp"] = @([timestamp longLongValue]);
        data[@"req_token"] = [self.class hash:token second:timestamp];

        NSData *encoded = [[self.class encodeQuery:data] dataUsingEncoding:NSASCIIStringEncoding];

        [self setHTTPBody: encoded];
        [self setValue:[NSString stringWithFormat:@"%d", (int)encoded.length] forHTTPHeaderField:@"Content-Lenght"];
        [self setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    return self;
}

@end
