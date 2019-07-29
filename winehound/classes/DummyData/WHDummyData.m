//
//  WHDummyData.m
//  WineHound
//
//  Created by Mark Turner on 04/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "WHDummyData.h"

@implementation WHDummyData

+ (void)setupHTTPStubs
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return ([request.URL.absoluteString rangeOfString:@"http://0.0.0.0:5000/api/wineries"].location != NSNotFound);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"wineries.json",nil)
                                                 statusCode:200
                                                    headers:@{@"Content-Type":@"application/json"}]
                requestTime:0.1 responseTime:OHHTTPStubsDownloadSpeedEDGE];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return ([request.URL.absoluteString rangeOfString:@"http://0.0.0.0:5000/api/regions"].location != NSNotFound);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"regions.json",nil)
                                                 statusCode:200
                                                    headers:@{@"Content-Type":@"application/json"}]
                requestTime:0.1 responseTime:OHHTTPStubsDownloadSpeedEDGE];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return ([request.URL.absoluteString rangeOfString:@"http://0.0.0.0:5000/api/wines"].location != NSNotFound);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"wines.json",nil)
                                                 statusCode:200
                                                    headers:@{@"Content-Type":@"application/json"}]
                requestTime:0.1 responseTime:OHHTTPStubsDownloadSpeedEDGE];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return ([request.URL.absoluteString rangeOfString:@"http://0.0.0.0:5000/api/events"].location != NSNotFound);
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [[OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"events.json",nil)
                                                 statusCode:200
                                                    headers:@{@"Content-Type":@"application/json"}]
                requestTime:0.1 responseTime:OHHTTPStubsDownloadSpeedEDGE];
    }];
}
@end
