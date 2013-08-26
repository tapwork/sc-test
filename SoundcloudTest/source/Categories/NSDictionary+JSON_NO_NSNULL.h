//
//  NSDictionary+JSON_NO_NSNULL.h
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON_NO_NSNULL)


- (id)jsonObjectForKey:(id)key;

@end
