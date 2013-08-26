//
//  SCApiManager.h
//  SoundcloudTest
//
//  Created by Christian Menschel on 24.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SCApiManagerCouldNotRefreshSessionNotification;


@interface SCApiManager : NSObject


@property (nonatomic, readonly) NSURL *baseURL;
@property (nonatomic, readonly) BOOL hasSession; // is the session valid (and user logged in)


+ (instancetype)sharedInstance;

/**
  Login to Soundcloud
 
  @param username
  @param password
  @completion your completion block, a success boolean will be sent that inidicates if the login was successful
 */
- (void)loginWithUsername:(NSString*)user
                 password:(NSString*)password
               completion:(void(^)(BOOL success))completion;





/**
  allows you to get information about the authenticated user and easily access his related subresources like tracks, followings, followers, groups and so on.
 

 @completion your completion block, the response will show you all requested infos about the user
 */
- (void)requestInfoAboutMeWithCompletion:(void(^)(NSDictionary *response))completion;


- (void)requestTracksWithCompletion:(void(^)(NSArray *tracks))completion;

/*
 Logout current user
 */
- (void)logout;


@end
