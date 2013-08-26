//
//  NSDictionary+JSON_NO_NSNULL.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import "NSDictionary+JSON_NO_NSNULL.h"

@implementation NSDictionary (JSON_NO_NSNULL)

- (id)jsonObjectForKey:(id)key
{
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;
    
    return object;
}


@end
