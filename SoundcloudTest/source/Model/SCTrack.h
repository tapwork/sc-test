//
//  SCModel.h
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCTrack : NSObject

@property (nonatomic, readonly) NSInteger uid;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *descriptionText;

@property (nonatomic, readonly) BOOL downloadable;
@property (nonatomic, readonly) NSDate *createdAt;


//
//  Some URLs
//
@property (nonatomic, readonly) NSURL *artWorkURL;
@property (nonatomic, readonly) NSURL *downloadURL;
@property (nonatomic, readonly) NSURL *permalinkURL;
@property (nonatomic, readonly) NSURL *streamURL;
@property (nonatomic, readonly) NSURL *waveformURL;
@property (nonatomic, readonly) NSURL *URI;
@property (nonatomic, readonly) NSURL *soundcloudAppURI;



- (id)initWithDictionary:(NSDictionary*)dict;


@end
