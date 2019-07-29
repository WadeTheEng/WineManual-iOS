//
//  Constants.h
//  WineHound
//
//  Created by Mark Turner on 24/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#ifndef WineHound_Constants_h
#define WineHound_Constants_h

#if STAGING
static NSString *const kBaseURLString = @"http://winehound-staging.herokuapp.com";
#else
static NSString *const kBaseURLString = @"http://app.winehound.net.au";
#endif

static NSString * const kGMSAPIKey = @"AIzaSyDwTLlqJJ0v7ffW-Gaff7dBTzWTaGNTifw";
static NSString * const kMixPanelToken = @"222cd4f14f24a8054ba12d337653efe3";
static NSString * const kBugSenseAPIKey = @"8822a0a5";
static NSString * const kForecastIOAPIKey = @"b1dfcbb85565073e4e3fa55f6e3ceecd";
static NSString * const kKochavaTrackerAPI = @"kowinehound250352f8748e530b5";
static NSString * const kInstabugToken = @"fd0926e6e224bfdbc757f2f7ed2e7827";
static NSString * const kWinehoundShareURL = @"http://goo.gl/8XEy2u";
static NSString * const kAppFireworksAPIKey = @"Cc1I2jgbqsZZ1j3QnDolavCh2i1rOPBQ";
static NSString * const kFacebookAppId = @"253213478173281";
static NSString * const kTestFlightAPI = @"6a621df1-7290-41fd-a017-67a6fde4d4f5";

#endif
