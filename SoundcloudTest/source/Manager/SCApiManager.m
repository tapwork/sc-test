//
//  SCApiManager.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 24.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import "SCApiManager.h"
#import "SCTrack.h"
#import "KeychainItemWrapper.h"

NSString *const kSCClientID = @"5144ff7600330fe258d8c8d6545d4455";
NSString *const kSCClientSecret = @"4d369909f7956ea7fb8c2fde3dc7845f";

NSString *const kSoundcloudConnectURLString = @"https://soundcloud.com/connect";

NSString *const kAccessTokenStoreKey = @"access_token";
NSString *const kRefreshTokenStoreKey = @"refresh_token";
NSString *const kTokenExpireDateStoreKey = @"expire_date_token";
NSString *const kSCKeyChainAccessGroup = @"SoundcloudKeyChainAccessGroup";


NSString *const SCApiManagerCouldNotRefreshSessionNotification = @"_ApiManagerCouldNotRefreshSessionNotification";

static NSDateFormatter *KRootViewDateFormatter = nil;

@implementation SCApiManager
{
    NSOperationQueue *_queue;
    NSString *_accessToken;
    NSString *_refreshToken;
    NSDate *_sessionExpireDate;
    
}
#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        
        _accessToken = [self storedAccessToken];
        _refreshToken = [self storedRefreshToken];
        _sessionExpireDate = [self storedTokenExpireDate];

    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SCApiManager *shared = nil;
    dispatch_once(&onceToken, ^{
        shared = [[SCApiManager alloc] init];
    });
    
    return shared;
}

#pragma mark - public API methods
- (void)logout
{
    [self storeAccessToken:nil];
    [self storeRefreshToken:nil];
    [self storeTokenExpireDate:nil];
}

//
// TODO: reverse engineered
// I had to reverse engineer the API with charles proxy,
// because there is no hint in the API documentation
// about the authentication (token) with username and password
// I could have used the SoundcloudUI SDK
// but as told me I tried to build this guy from scratch
// nevertheless an API method to authenticate with username & password would be neat
//
//
- (void)loginWithUsername:(NSString*)user
                 password:(NSString*)password
               completion:(void(^)(BOOL success))completion
{
    //
    // logout before
    //
    [self logout];
    
    NSURL *url = [[self baseURL] URLByAppendingPathComponent:@"oauth2/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    NSString* requestStr = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=%@&username=%@&password=%@",
                            kSCClientID,kSCClientSecret,@"password",user,password];
    NSData *requestData = [NSData dataWithBytes:[requestStr UTF8String ] length: [requestStr length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: requestData];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (completion)
                               {
                                   NSError *jsonReadError = nil;
                                   id json = nil;
                                   if (data)
                                   {
                                       json = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:&jsonReadError];
                                       
                                       [self storeSession:json];
                                   }
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       //
                                       // dispatch it on the main queue
                                       // because this goes back to UIViewController
                                       if (completion)
                                       {
                                           completion(_accessToken != nil);
                                       }
                                       
                                   });
                               }
                           }];
}



- (void)requestInfoAboutMeWithCompletion:(void(^)(NSDictionary *response))completion
{
    [self performAPIMethod:@"me" completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *jsonReadError = nil;
        id json = nil;
        if (data)
        {
            json = [NSJSONSerialization JSONObjectWithData:data
                                                   options:NSJSONReadingMutableContainers
                                                     error:&jsonReadError];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion)
            {
                completion(json);
            }
        });
    }];
}


- (void)requestTracksWithCompletion:(void(^)(NSArray *tracks))completion
{
    //
    // TODO: me/activities/tracks
    // the method me/activities/tracks seems not to be official
    // I could not find it in the docs
    // found me/activities and tracks as individual method
    // stackoverflow helped me here
    //
    [self performAPIMethod:@"me/activities/tracks"
                completion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    NSError *jsonReadError = nil;
                    NSMutableArray *tracks = [NSMutableArray array];
                    if (data)
                    {
                        id json = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&jsonReadError];
                        for (NSDictionary *trackDict in json[@"collection"])
                        {
                            SCTrack *track = [[SCTrack alloc] initWithDictionary:trackDict];
                            [tracks addObject:track];
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion)
                        {
                            completion(tracks);
                        }
                    });
                }];
}


#pragma mark - private api methods
- (void)refreshSessionWithCompletion:(void(^)(BOOL success))completion
{

    NSURL *url = [[self baseURL] URLByAppendingPathComponent:@"oauth2/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    NSString* requestStr = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=%@&refresh_token=%@",
                            kSCClientID,kSCClientSecret,@"refresh_token",_refreshToken];
    NSData *requestData = [NSData dataWithBytes:[requestStr UTF8String ] length: [requestStr length]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody: requestData];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (completion)
                               {
                                   NSError *jsonReadError = nil;
                                   id json = nil;
                                   if (data)
                                   {
                                       json = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingMutableContainers
                                                                                error:&jsonReadError];
                                       
                                       [self storeSession:json];
                                   }
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (connectionError)
                                       {
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:SCApiManagerCouldNotRefreshSessionNotification
                                            object:nil];
                                       }
                                       
                                       if (completion)
                                       {
                                           completion(_accessToken != nil);
                                       }
                                       
                                   });
                               }
                           }];
}


- (void)performAPIMethod:(NSString*)apiMethod
              completion:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))completion
{
    if ([self isSessionValid] == NO)
    {
        [self refreshSessionWithCompletion:^(BOOL success) {
            if (success)
            {
                [self performAPIMethod:apiMethod completion:completion];
            }
        }];
        
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/%@.json?oauth_token=%@",
                           [[self baseURL] absoluteString],
                           apiMethod,
                           _accessToken];
    NSURLRequest *request = [[NSURLRequest alloc]
                             initWithURL:[NSURL URLWithString:urlString]
                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:_queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (completion)
                               {
                                   completion(response,data,connectionError);
                               }
                           }];
}

#pragma mark - Session Handling & Keychain
- (void)storeSession:(NSDictionary*)session
{
    NSString* accessToken = session[@"access_token"];
    NSString *refreshToken = session[@"refresh_token"];
    NSTimeInterval tokenExpireInterval = [session[@"expires_in"] doubleValue];
    NSDate *date = [[NSDate date] initWithTimeInterval:tokenExpireInterval sinceDate:[NSDate date]];
    
    [self storeAccessToken:accessToken];
    [self storeRefreshToken:refreshToken];
    [self storeTokenExpireDate:date];
    
}

- (void)storeAccessToken:(NSString*)token
{
    _accessToken = token;
    
#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kAccessTokenStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return;
#endif
    
    
    NSString *accessGroup = [[NSUserDefaults standardUserDefaults]
                             objectForKey:kSCKeyChainAccessGroup];
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc]
                                    initWithIdentifier:@"Authentication"
                                    accessGroup:accessGroup];
    [wrapper setObject:token forKey:(__bridge id)kSecValueData];
    
}

- (NSString*)storedAccessToken
{
#if TARGET_IPHONE_SIMULATOR
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenStoreKey];
#endif
    
    NSString *accessGroup = [[NSUserDefaults standardUserDefaults] objectForKey:kSCKeyChainAccessGroup];
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Authentication" accessGroup:accessGroup];
    NSString* token = [wrapper objectForKey:(__bridge id)kSecValueData];
    
   
    return token;

}

- (void)storeRefreshToken:(NSString*)token
{
    _refreshToken = token;
    
#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kRefreshTokenStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return;
#endif
    
   
    NSString *accessGroup = [[NSUserDefaults standardUserDefaults]
                             objectForKey:kSCKeyChainAccessGroup];
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc]
                                    initWithIdentifier:@"Authentication"
                                    accessGroup:accessGroup];

    [wrapper setObject:token forKey:(__bridge id)kSecAttrLabel];
    
}

- (NSString*)storedRefreshToken
{
#if TARGET_IPHONE_SIMULATOR
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRefreshTokenStoreKey];
#endif
    
    NSString *accessGroup = [[NSUserDefaults standardUserDefaults] objectForKey:kSCKeyChainAccessGroup];
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Authentication" accessGroup:accessGroup];
    NSString* token = [wrapper objectForKey:(__bridge id)kSecAttrLabel];
    
    return token;
}

- (void)storeTokenExpireDate:(NSDate*)date
{
    _sessionExpireDate = date;
    
#if TARGET_IPHONE_SIMULATOR
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kTokenExpireDateStoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return;
#endif
    
    NSString *lastAuthDateAsString = [[self dateFormatter] stringFromDate:date];
    NSString *accessGroup = [[NSUserDefaults standardUserDefaults]
                             objectForKey:kSCKeyChainAccessGroup];
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc]
                                    initWithIdentifier:@"Authentication"
                                    accessGroup:accessGroup];
    

    [wrapper setObject:lastAuthDateAsString forKey:(__bridge id)kSecAttrDescription];
    
}

- (NSDate*)storedTokenExpireDate
{
#if TARGET_IPHONE_SIMULATOR
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTokenExpireDateStoreKey];
#endif
    
    NSString *accessGroup = [[NSUserDefaults standardUserDefaults] objectForKey:kSCKeyChainAccessGroup];
    KeychainItemWrapper* wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Authentication" accessGroup:accessGroup];
    NSString *dateString = [wrapper objectForKey:(__bridge id)kSecAttrDescription];
   
    
    return [[self dateFormatter] dateFromString:dateString];
}


#pragma mark - Getter

- (NSURL*)baseURL
{
    NSDictionary *infoDic = [[NSBundle bundleForClass:[self class]] infoDictionary];
    NSString *baseURLString = infoDic[@"SC API Base URL"];
    
    return [NSURL URLWithString:baseURLString];
}

- (NSDateFormatter*)dateFormatter
{
    if (KRootViewDateFormatter == nil)
    {
        KRootViewDateFormatter = [[NSDateFormatter alloc] init];
        [KRootViewDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        [KRootViewDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [KRootViewDateFormatter setTimeZone:timeZone];
    }
    
    return KRootViewDateFormatter;
}

- (BOOL)hasSession
{
    return (_accessToken != nil);
}

- (BOOL)isSessionValid
{
    NSTimeInterval intv = [_sessionExpireDate timeIntervalSinceDate:[NSDate date]];
    return ([self hasSession] && intv > 0);
}



@end
