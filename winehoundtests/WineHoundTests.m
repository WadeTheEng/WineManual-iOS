//
//  WineHoundTests.m
//  WineHoundTests
//
//  Created by Tomas Spacek on 26/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>

@interface LoginTests : KIFTestCase
@end

@implementation LoginTests

- (void)testTabsAppear
{
    [tester waitForTappableViewWithAccessibilityLabel:@"First"];
}

@end