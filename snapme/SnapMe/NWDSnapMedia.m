//
//  NWDSnapMedia.m
//  SnapMe
//
//  Created by Romain Arsac on 23/09/2014.
//  Copyright (c) 2014 Nyu Web Developpement. All rights reserved.
//

#import "NWDSnapMedia.h"
#import <objc/runtime.h>

@implementation NWDSnapMedia

+ (NSString *) getDate:(float)timestamp
{
    char * periods[] = {"seconde", "minute", "heure", "jour", "semaine", "mois", "annee", "decenie"};
    double lengths[] = { 60, 60, 24, 7, 4.35, 12, 10};
    int now = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
    double difference = now - (timestamp / 1000);
    int j;
    for(j = 0; difference >= lengths[j] && j < 6; j++) {
        difference /= lengths[j];
    }

    difference = round(difference);

    NSString * result = [NSString stringWithUTF8String:periods[j]];;

    if (difference != 1 && ![result isEqual:@"mois"]) {
        result = [result stringByAppendingString:@"s"];
    }
    return [NSString stringWithFormat:@"Il y a %d %@", (int)difference, result];
}

+ (BOOL) isMedia:(NSData *)data
{
    if (!data)
        return NO;
    if (((const unsigned char *)data.bytes)[0] == 0xff || ((const unsigned char *)data.bytes)[1] == 0xd8)
        return YES;
    if (((const unsigned char *)data.bytes)[0] == 0x00 || ((const unsigned char *)data.bytes)[1] == 0x00)
        return YES;
    if (((const unsigned char *)data.bytes)[0] == 0x89)
        return YES;
    return NO;
}
//A repasser en object
+(NSMutableArray*)deserialize:(NSString*)fileName
{
    NSString *pathRoot = [[NSUserDefaults standardUserDefaults] stringForKey:@"pathToSnapMe"];
    NSString *filePath = [pathRoot stringByAppendingString:[@"/" stringByAppendingString:fileName]];
    
    NSFileManager *man = [[NSFileManager alloc] init];
    if (!man || ![man fileExistsAtPath:filePath])
        return (nil);
    Class clazz = [self class];
    u_int count;
    objc_property_t* propList = class_copyPropertyList(clazz, &count);

    NSError         *error;
    NSInputStream *iS = [[NSInputStream alloc] initWithFileAtPath:filePath];
    [iS open];

    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parseJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (error)
    {
        NSLog(@"Error deserialize: %@", error);
    }
    NSMutableArray *res = [[NSMutableArray alloc] init];
    NSArray *snapMedias = [parseJson objectForKey:[NSString stringWithCString:class_getName(clazz) encoding:NSUTF8StringEncoding]];
    for (NSDictionary *snaps in snapMedias)
    {
        NWDSnapMedia *result = [[NWDSnapMedia alloc] init];
        NSArray *keys = [snaps allKeys];
       for (NSString *key in keys)
       {
           for (u_int i = 0; i < count; ++i)
           {
               objc_property_t property = propList[i];
               const char *propName = property_getName(property);
               NSString *propNameString = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];

               if ([key isEqual:propNameString])
               {
                   const char * type = property_getAttributes(property);
                   NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
                   NSString *value = [snaps objectForKey:key];
                   //NSLog(@"Deserialize Value: %@", value);
                   if ([attr containsString:@"Tq"])
                   {
                      [result setValue:value forKey:key];
                   }
                   /*else if ([attr containsString:@"UIImage"])
                   {
                       NSData  *dataImage = [[NSData alloc]initWithBase64EncodedString:value                                                                               options:NSDataBase64DecodingIgnoreUnknownCharacters];
;
                       UIImage *img = [[UIImage alloc] initWithData:dataImage];
                       if (img == nil)
                           NSLog(@"FAILED TO ADD Image");
                      // NSLog(@"DES Adding UIImage to json");
                       [result setValue:img forKey:key];
                   }*/
                   else if ([attr containsString:@"NSURL"])
                   {
                     //  NSLog(@"DES Adding NSURL to json");
                       //Fixed lien vers videos mais trop d'opération sur des strings je trouves... Trop d'alloc
                       NSString *pathToFile = [pathRoot stringByAppendingString:[@"/" stringByAppendingString:value]];
                       NSURL   *url = [NSURL fileURLWithPath:[pathToFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                       
                       [result setValue:url forKey:key];

                   }
                   else if ([attr containsString:@"NSString"])
                   {
                      // NSLog(@"DES %@", value);
                       [result setValue:value forKey:key];
                   }
               }
            }
       }
        [res addObject:result];
    }
    [iS close];
    return res;
}

-(NSString*)serialize
{
    Class clazz = [self class];
    NSMutableString *result = [[NSMutableString alloc] init];
    u_int count;
    objc_property_t* propList = class_copyPropertyList(clazz, &count);
    NSMutableDictionary    *dico = [[NSMutableDictionary alloc]init];
    
    for (u_int i = 0; i < count; ++i)
    {
        objc_property_t property = propList[i];
        const char *propName = property_getName(property);
        NSString *propNameString = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
        const char * type = property_getAttributes(property);
        NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];

        NSLog(@"PropName: %@, Type: %@", propNameString, attr);
        if ([attr containsString:@"Tq"])
        {
            [dico setObject:[NSString stringWithFormat: @"%d", (int)[self valueForKey:propNameString]] forKey:propNameString];
        }
        else if ([attr containsString:@"TQ"])
        {
            [dico setObject:[NSString stringWithFormat: @"%llu", (unsigned long long)[self valueForKey:propNameString]] forKey:propNameString];
        }
       /* else if ([attr containsString:@"UIImage"] && [self valueForKey:propNameString])
        {
          //  NSLog(@"Adding UIImage to json");

            NSData *imageData = UIImageJPEGRepresentation(self.mediaImage, 1.0);
            NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            [dico setObject:imageString forKey:propNameString];
        }*/
        else if ([attr containsString:@"NSURL"] && [self valueForKey:propNameString])
        {
          //  NSLog(@"Adding NSURL to json");
            NSURL *url = (NSURL*) [self valueForKey:propNameString];
            NSString *str = [url path];
            NSArray *parts = [str componentsSeparatedByString:@"/"];
            //count - 2 pour avoir le nom de l'utilisateur a qui appartient le snap envoyé
            NSMutableString *filename = [[NSMutableString alloc] init];
            [filename appendString:[parts objectAtIndex:[parts count]-2]];
            [filename appendString:@"/"];
            [filename appendString:[parts objectAtIndex:[parts count]-1]];
            NSLog(@"Filename: %@", filename);
            [dico setObject:filename forKey:propNameString];
        }
        else if ([attr containsString:@"NSString"] && [self valueForKey:propNameString])
            [dico setObject:[self valueForKey:propNameString] forKey:propNameString];
    }
  //  NSLog(@"Size of dico: %lu", (unsigned long)[dico count]);
    NSError *error = nil;
    // Fuite ici negro wesh rpz la memoire
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dico
                                                       options:(NSJSONWritingPrettyPrinted)
                                                         error:&error];
    if (error)
        NSLog(@"Error Serialize : %@", error);
    else
    {
        NSString *jsonRes = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [result appendString:jsonRes];
       // NSLog(@"JSON Serialized : %@", result);
    }
    return result;
}

-(NSString*)serialize:(NSString*)fileName
{
    NSString *json = [self serialize];
    
    if (json)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSFileManager   *manager = [NSFileManager defaultManager];
            NSString *pathRoot = [[NSUserDefaults standardUserDefaults]
                                  stringForKey:@"pathToSnapMe"];
          //Peut etre ajouter le "/"
            NSString *filePath = [pathRoot stringByAppendingString:[@"/" stringByAppendingString:fileName]];
            if ([manager fileExistsAtPath:filePath])
            {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:[json dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else
                [json writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        });
        return (json);
    }
    return (nil);
}


@end
