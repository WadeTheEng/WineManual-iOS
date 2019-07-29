//
//  WHEventMO+Additions.m
//  WineHound
//
//  Created by Mark Turner on 23/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHEventMO+Additions.h"
#import "NSCalendar+WineHound.h"

//Required for WHShareProtocol
#import <CCTemplate/CCTemplate.h>
#import "WHPhotographMO.h"
#import "WHWineryMO.h"

#import <CoreLocation/CLLocation.h>
#import <objc/runtime.h>

static char kWHEventLocationKey;
static char kWHSharedDateFormatterKey;

static NSDateFormatter * _publicDateFormatter;

@implementation WHEventMO (Additions)
@dynamic location,isFeatured;


#pragma mark
#pragma mark Location

- (CLLocation *)location
{
    CLLocation * location = (CLLocation *)objc_getAssociatedObject(self, &kWHEventLocationKey);
    if (location == nil) {
        location = [[CLLocation alloc] initWithLatitude:self.latitude.doubleValue longitude:self.longitude.doubleValue];
        [self setLocation:location];
    }
    return location;
}

- (void)setLocation:(CLLocation *)location
{
    objc_setAssociatedObject(self, &kWHEventLocationKey, location, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)didTurnIntoFault
{
    [self setLocation:nil];
}

#pragma mark
#pragma mark

- (NSDateFormatter *)sharedDateFormatter
{
    NSDateFormatter * dateFormatter = (NSDateFormatter *)objc_getAssociatedObject(self, &kWHSharedDateFormatterKey);
    if (dateFormatter == nil) {
        if (_publicDateFormatter == nil) {
             dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"]];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            /*
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            */
            _publicDateFormatter = dateFormatter;
        }
        return _publicDateFormatter;
    }
    return dateFormatter;
}

- (void)setSharedDateFormatter:(NSDateFormatter *)sharedDateFormatter
{
    objc_setAssociatedObject(self, &kWHSharedDateFormatterKey, sharedDateFormatter, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isFeatured
{
    return self.featured.boolValue;
}

- (NSString *)datePeriodString
{
    return [self datePeriodStringTruncated:NO];
}

- (NSString *)shortDatePeriodString
{
    return [self datePeriodStringTruncated:YES];
}


- (NSString *)datePeriodStringTruncated:(BOOL)truncated
{
    NSString * datePeriodString = nil;
    
    NSAssert(self.sharedDateFormatter != nil, @"Error - Provide a dateformatter.");

    [self.sharedDateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [self.sharedDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"]];
    [self.sharedDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    if (self.startDate != nil && self.finishDate != nil) {
        
        NSCalendar * calendar = [NSCalendar wh_sharedCalendar];

        NSDateComponents * startDateComponents  = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.startDate];
        NSDateComponents * finishDateComponents = [calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.finishDate];
        
        datePeriodString = [NSString new];
        
        BOOL sameDay   = (startDateComponents.day   == finishDateComponents.day);
        BOOL sameMonth = (startDateComponents.month == finishDateComponents.month);
        BOOL sameYear  = (startDateComponents.year  == finishDateComponents.year);
        
        if (sameDay && sameMonth && sameYear) {
            //Display date as 'Fri 21st February'
            [self.sharedDateFormatter setDateFormat:@"EEE"];

            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];
            datePeriodString = [datePeriodString stringByAppendingString:[self dayStringWithSuffixForDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];

            [self.sharedDateFormatter setDateFormat:truncated?@"MMM":@"MMMM"];
            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.startDate]];
            
        } else if (sameMonth && sameYear) {
            //Display date as 'Fri 21st - 23rd February'
            [self.sharedDateFormatter setDateFormat:@"EEE"];
            
            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];
            
            datePeriodString = [datePeriodString stringByAppendingString:[self dayStringWithSuffixForDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" - "];
            datePeriodString = [datePeriodString stringByAppendingString:[self dayStringWithSuffixForDate:self.finishDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];

            [self.sharedDateFormatter setDateFormat:truncated?@"MMM":@"MMMM"];
            
            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.finishDate]];
            
        } else {
            //Display date is 'Fri 28th February - 16th March'
            [self.sharedDateFormatter setDateFormat:@"EEE"];
            
            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];
            
            datePeriodString = [datePeriodString stringByAppendingString:[self dayStringWithSuffixForDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];

            [self.sharedDateFormatter setDateFormat:truncated?@"MMM":@"MMMM"];
            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.startDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" - "];
            datePeriodString = [datePeriodString stringByAppendingString:[self dayStringWithSuffixForDate:self.finishDate]];
            datePeriodString = [datePeriodString stringByAppendingString:@" "];
            
            [self.sharedDateFormatter setDateFormat:truncated?@"MMM":@"MMMM"];
            datePeriodString = [datePeriodString stringByAppendingString:[self.sharedDateFormatter stringFromDate:self.finishDate]];
            
            //Check if the year is the current year...
        }
    }
    return datePeriodString;
}

- (NSString *)dayStringWithSuffixForDate:(NSDate *)date
{
    [self.sharedDateFormatter setDateFormat:@"d"];
    
    NSString * dayString = [self.sharedDateFormatter stringFromDate:date];
    int date_day = [dayString intValue];
    
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray  *suffixes      = [suffix_string componentsSeparatedByString: @"|"];
    NSString *suffix        = [suffixes objectAtIndex:date_day];
    
    return [dayString stringByAppendingString:suffix];
}

#pragma mark WHShareProtocol

- (NSString *)shareTitle
{
    return [NSString stringWithFormat:@"Share this Event"];
}

- (NSString *)facebookShareString
{
    return [NSString stringWithFormat:@"Check out this event, %@, I found using the Winehound app %@",self.name,self.shareURL];
}

- (NSString *)twitterShareString
{
    return [NSString stringWithFormat:@"Check out this event on the #WineHoundApp %@",self.shareURL];
}

- (NSString *)smsShareString
{
    return [NSString stringWithFormat:@"Check out this event, %@, I found using the Winehound app %@. Available on the iTunes App Store and Google Play Store",self.name,self.shareURL];
}

- (NSString *)shareURL
{
    return [NSString stringWithFormat:@"http://app.winehound.net.au/share/event/%@",self.eventId];
}

- (id)trackProperties
{
    return @{@"event_id": self.eventId};
}

- (NSString *)emailSubject
{
    return @"Check out this event.";
}

- (NSString *)emailBody;
{
    WHPhotographMO * eventPhotograph = [self.photographs firstObject];
    NSString * eventThumbURL = eventPhotograph.imageThumbURL;
    
    WHWineryMO * winery = [self.wineries anyObject];
    
    /*
     
     When: %@ <br>
     Where: %@
     
     */
    
    NSDictionary * dict = @{@"winery_name"   :winery.name ?: @"",
                            @"share_intro"   :@"Check out this great event coming up:",
                            @"share_location":self.name ?: @"",
                            @"share_url"     :self.shareURL,
                            @"share_body"    :[NSString stringWithFormat:@"When: %@ <br> Where: %@",self.datePeriodString,self.locationName],
                            @"share_footer"  :@"You can learn more about Australian wineries and other upcoming events on the WineHound app.",
                            @"image_url"     :eventThumbURL ?: @""
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


@end