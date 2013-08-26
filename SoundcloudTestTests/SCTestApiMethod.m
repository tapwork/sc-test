//
//  SCTestApiMethod.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SCApiManager.h"

@interface SCApiManager (private)

- (void)storeSession:(NSDictionary*)session;
- (NSString*)storedAccessToken;
- (NSString*)storedRefreshToken;
- (NSDate*)storedTokenExpireDate;
- (void)logout;

@end


@interface SCTestApiMethod : XCTestCase

@end

@implementation SCTestApiMethod

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testLogout
{
    
    [[SCApiManager sharedInstance] logout];
    NSString *storedAccessToken = [[SCApiManager sharedInstance] storedAccessToken];
    NSString *storedRefreshToken = [[SCApiManager sharedInstance] storedRefreshToken];
    NSDate *storedTokenExpireDate = [[SCApiManager sharedInstance] storedTokenExpireDate];
    
    XCTAssertNil(storedAccessToken,  @"must be nil");
    XCTAssertNil(storedRefreshToken, @"must be nil");
    XCTAssertNil(storedTokenExpireDate, @"must  be nil");
    
}

- (void)testSessionStorage
{
    NSDictionary *dict = @{@"access_token" : @"fddfjjerjkhfdjkfnjkfgjkfgjkfgj",
                           @"refresh_token" : @"238fnfjerjjhrhjdf",
                           @"expires_in" : @"2444"};
    
    
    [[SCApiManager sharedInstance] storeSession:dict];
    NSString *storedAccessToken = [[SCApiManager sharedInstance] storedAccessToken];
    NSString *storedRefreshToken = [[SCApiManager sharedInstance] storedRefreshToken];
    NSDate *storedTokenExpireDate = [[SCApiManager sharedInstance] storedTokenExpireDate];
    
    XCTAssertEqualObjects(storedAccessToken, dict[@"access_token"], @"must be equal");
    XCTAssertEqualObjects(storedRefreshToken, dict[@"refresh_token"], @"must be equal");
    XCTAssertNotNil(storedTokenExpireDate, @"must not be nil");
    
}


@end
