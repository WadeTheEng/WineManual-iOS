//
//  WHWineMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 10/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <CCTemplate/CCTemplate.h>

#import "WHWineMO+Additions.h"
#import "WHWineryMO.h"
#import "WHPhotographMO.h"

@implementation WHWineMO (Additions)

- (NSString *)costString
{
    if (self.cost.floatValue == 0) {
        return [self cost];
    }
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"au_AU"]];
    return [numberFormatter stringFromNumber:@(self.cost.floatValue)];
}

#pragma mark WHShareProtocol

- (NSString *)shareTitle
{
    return [NSString stringWithFormat:@"Share this Wine"];
}

- (NSString *)facebookShareString
{
    return [NSString stringWithFormat:@"Check out this wine, %@, I found using the Winehound app %@",self.name,self.shareURL];
}

- (NSString *)twitterShareString
{
    return [NSString stringWithFormat:@"Check out this wine on the #WineHoundApp %@",self.shareURL];
}

- (NSString *)smsShareString
{
    return [NSString stringWithFormat:@"Check out this wine from %@ I found using the WineHound app %@. Available on the iTunes App Store and Google Play Store",self.name,self.shareURL];
}

- (NSString *)shareURL
{
    WHWineryMO * winery = [self.wineries anyObject];
    return [NSString stringWithFormat:@"http://app.winehound.net.au/share/winery/%@",winery.wineryId];
}

- (NSString *)emailSubject
{
    WHWineryMO * winery = [self.wineries anyObject];
    return [NSString stringWithFormat:@"Another great wine from: %@",winery.name];
}

- (NSString *)emailBody;
{
    WHWineryMO     * winery    = [self.wineries anyObject];
    WHPhotographMO * wineThumb = [self.photographs firstObject];
    NSString * wineThumbURL = wineThumb.imageWineThumbURL;
    
    if (wineThumbURL == nil) {
        NSLog(@"Don't print wine thumb");
    }
    
    NSString * shareFooter = [NSString stringWithFormat:@"You can learn more about %@, their Cellar Door and upcoming events with the Winehound app in the App Store.",winery.name ?: @"Australian wineries"];
    NSDictionary * dict = @{@"winery_name"   :winery.name ?: @"",
                            @"share_intro"   :@"Check out this great wine from:",
                            @"share_location":[NSString stringWithFormat:@"%@ : %@",self.name,winery.name],
                            @"share_url"     :self.shareURL,
                            @"share_body"    :@"Keep an eye out for it... definitely worth trying.",
                            @"share_footer"  :shareFooter,
                            @"image_url"     :wineThumbURL  ?: @""
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

- (id)trackProperties
{
    return @{@"wine_id": self.wineId};
}

@end
