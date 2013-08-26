//
//  SCModel.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import "SCTrack.h"
#import "NSDictionary+JSON_NO_NSNULL.h"

static NSDateFormatter *kCreatedtDateFormatter = nil;

@implementation SCTrack


- (id)initWithDictionary:(NSDictionary*)dict
{
    self = [super init];
    if (self) {
        
        if (kCreatedtDateFormatter == nil)
        {
            kCreatedtDateFormatter = [[NSDateFormatter alloc] init];
            [kCreatedtDateFormatter setDateFormat:@"yyyy/MM/dd hh:mm:ss +0000"];  // rarely seen this dateforma
        }
        if ([dict jsonObjectForKey:@"created_at"])
        {
            _createdAt = [kCreatedtDateFormatter dateFromString:[dict jsonObjectForKey:@"created_at"]];
        }
        
        
        // TODO: properties in api doc could be in alphabetical order
        // BTW: the api properties (i.e. http://developers.soundcloud.com/docs/api/reference#tracks)
        // should be ordered by the property name
        // searching takes a long time
        //
        // TODO: NSNull !!! Also there are plenty of null objects in the API : <null>
        // in cocoa null will be handled as object
        // I had to add a NSDictionary category which does not return NSNull objects
        
        
        NSDictionary *origin        = [dict jsonObjectForKey:@"origin"];
        _uid                        = [[origin jsonObjectForKey:@"id"] integerValue];
        _title                      = [origin jsonObjectForKey:@"title"];
        _descriptionText            = [origin jsonObjectForKey:@"description"];
        _downloadable               = [[origin jsonObjectForKey:@"downloadable"] boolValue];
        _artWorkURL                 = [NSURL URLWithString:[origin jsonObjectForKey:@"artwork_url"]];
        _downloadURL                = [NSURL URLWithString:[origin jsonObjectForKey:@"download_url"]];
        _permalinkURL               = [NSURL URLWithString:[origin jsonObjectForKey:@"permalink_url"]];
        _streamURL                  = [NSURL URLWithString:[origin jsonObjectForKey:@"stream_url"]];
        
        // TODO: waveform image are pretty big for iOS ( I had one with 1800x280 pixels)
        // is there also a small URL version?
        // would be less loading time and better for rendering
        // Much better would be an image resizing method via URL parameter
        // i.e. http://w1.sndcdn.com/u04ibjx6FYdM_m.png?size=100.0,70.0
        
        _waveformURL                = [NSURL URLWithString:[origin jsonObjectForKey:@"waveform_url"]];
        _URI                        = [NSURL URLWithString:[origin jsonObjectForKey:@"uri"]];
        _soundcloudAppURI           = [NSURL URLWithString:[NSString stringWithFormat:@"soundcloud://sounds:%d",self.uid]];
        
    }
    return self;
}




- (NSUInteger)hash
{
    return [self.URI hash];
}

- (BOOL)isEqual:(id)object
{
    return ([object isKindOfClass:[self class]] &&
            [self hash] == [object hash]);
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Soundcloud track: id: %d   title %@  uri %@\n\n",self.uid,self.title,self.URI];
}

@end
