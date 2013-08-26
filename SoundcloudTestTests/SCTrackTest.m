//
//  SCTrackTest.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 26.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SCTrack.h"

@interface SCTrackTest : XCTestCase

@end

@implementation SCTrackTest

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


- (NSDictionary *)jsonDict
{
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"track" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSError *jsonError = nil;
    
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
}

- (NSDateFormatter*)dateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss +0000"];
    
    return formatter;
}

- (void)testJSONModel
{
    
    NSDictionary *json = [self jsonDict];
    SCTrack *track = [[SCTrack alloc] initWithDictionary:json];
    NSDate *date = [[self dateFormatter] dateFromString:json[@"created_at"]];
    XCTAssertEqualObjects(track.createdAt, date, @"must be equal");
    NSDictionary *origin = json[@"origin"];
    XCTAssertEqualObjects([track.URI absoluteString], origin[@"uri"], @"must be equal");
    XCTAssertEqual(track.uid, [origin[@"id"] integerValue], @"must be equal");
    XCTAssertEqualObjects(track.title, origin[@"title"], @"must be equal");
    XCTAssertEqualObjects([track.artWorkURL absoluteString],
                          origin[@"artwork_url"], @"must be equal");
    XCTAssertEqualObjects([track.downloadURL absoluteString], origin[@"download_url"], @"must be equal");
    XCTAssertEqual(track.downloadable, [origin[@"downloadable"] boolValue], @"must be equal");
    XCTAssertEqualObjects([track.waveformURL absoluteString], origin[@"waveform_url"], @"must be equal");
    XCTAssertEqualObjects([track.streamURL absoluteString], origin[@"stream_url"], @"must be equal");
    XCTAssertEqualObjects([track.permalinkURL absoluteString], origin[@"permalink_url"], @"must be equal");
    

}

@end
