//
//  WHWineryMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 06/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <CCTemplate/CCTemplate.h>
#import <CoreLocation/CLLocation.h>
#import <objc/runtime.h>

#import "WHWineryMO+Additions.h"
#import "WHWineryMO+Mapping.h"
#import "WHPhotographMO.h"

static char kWHWineryLocationKey;

@implementation WHWineryMO (Additions)
@dynamic location;

#pragma mark
#pragma mark Location

- (CLLocation *)location
{
    CLLocation * location = (CLLocation *)objc_getAssociatedObject(self, &kWHWineryLocationKey);
    if (location == nil) {
        location = [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
        [self setLocation:location];
    }
    return location;
}

- (void)setLocation:(CLLocation *)location
{
    objc_setAssociatedObject(self, &kWHWineryLocationKey, location, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTurnIntoFault
{
    [self setLocation:nil];
}

#pragma mark
#pragma mark

- (BOOL)isPremium
{
    return (self.tierValue < WHWineryTierBasic);
}

- (BOOL)isGold
{
    return (self.tierValue <= WHWineryTierGold);
}

#pragma mark WHShareProtocol

- (NSString *)shareTitle
{
    return [NSString stringWithFormat:@"Share this Winery"];
}

- (NSString *)facebookShareString
{
    return [NSString stringWithFormat:@"Check out this winery, %@, I found using the Winehound app %@",self.name,self.shareURL];
}

- (NSString *)twitterShareString
{
    return [NSString stringWithFormat:@"Check out this winery on the #WineHoundApp %@",self.shareURL];
}

- (NSString *)smsShareString
{
    return [NSString stringWithFormat:@"Check out this winery, %@, I found using the Winehound app %@. Available on the iTunes App Store and Google Play Store",self.name,self.shareURL];
}


- (NSString *)shareURL
{
    return [NSString stringWithFormat:@"http://app.winehound.net.au/share/winery/%@",self.wineryId];
}

- (id)trackProperties
{
    return @{@"winery_id": self.wineryId};
}

- (NSString *)emailSubject
{
    return @"Check out this Winery";
}

- (NSString *)emailBody;
{
    WHPhotographMO * wineryThumb = [self.photographs firstObject];
    NSString * wineThumbURL = wineryThumb.imageThumbURL;
    
    if (wineThumbURL == nil) {
        NSLog(@"Don't print wine thumb");
    }
    
    NSString * shareFooter = [NSString stringWithFormat:@"You can learn more about %@, their Cellar Door and upcoming events with the Winehound app in the App Store.",self.name ?: @"Australian wineries"];
    NSDictionary * dict = @{@"winery_name"   :self.name ?: @"",
                            @"share_intro"   :@"Check out this great winery:",
                            @"share_location":self.name ?: @"",
                            @"share_url"     :self.shareURL,
                            @"share_body"    :@"",
                            @"share_footer"  :shareFooter,
                            @"image_url"     :wineThumbURL ?: @""
                            };
    
    NSError * error = nil;
    
    NSString * shareTemplateURL = [[NSBundle mainBundle] pathForResource:@"email_share_template" ofType:@"html"];
    NSString * template = [[NSString alloc] initWithContentsOfFile:shareTemplateURL encoding:NSUTF8StringEncoding error:&error];
    
    NSString * htmlBody = nil;
    if (error == nil) {
        htmlBody = [template templateFromDict:dict];
    }
    return htmlBody;
}

#pragma mark WHOpenHoursProtocol

- (NSSet *)openHoursSet
{
    return [self cellarDoorOpenTimes];
}

@end
