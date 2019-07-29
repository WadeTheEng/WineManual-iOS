//
//  NSAttributedString+OpenHours.m
//  WineHound
//
//  Created by Mark Turner on 21/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSAttributedString+OpenHours.h"

#import "WHOpenTimeMO+Mapping.h"
#import "NSCalendar+WineHound.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

static const int WHPublicHoliday = 8;
static const int WHByAppointment = 9;

NSString * const WHOpenTimeDays[] = {
    [0] = @"Everyday",
    [1] = @"Sunday",
    [2] = @"Monday",
    [3] = @"Tuesday",
    [4] = @"Wednesday",
    [5] = @"Thursday",
    [6] = @"Friday",
    [7] = @"Saturday",
    [WHPublicHoliday] = @"Public Holidays",
    [WHByAppointment] = @"Call ahead for tasting hours"
};

static inline NSString * wh_cellarOpenTimeString(int day) {
    if (day < 10) {
        return WHOpenTimeDays[day];
    }
    return nil;
}

@implementation NSAttributedString (OpenHours)

+ (NSAttributedString *)openHoursAttributedStringWithObject:(NSObject <WHOpenHoursProtocol> *)object
{
    if (NO == [object conformsToProtocol:@protocol(WHOpenHoursProtocol)])
        return [NSAttributedString new];
    
    if (object.openHoursSet.count <= 0) return [NSAttributedString new];
    
    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    /*
     MT NOTE - Time zones are not implemented.
     if (self.timezone != nil) {
     [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:self.timezone]];
     }
     [dateFormatter.calendar setFirstWeekday:nil];
     */
    
    NSMutableArray * openTimesLineArray = @[].mutableCopy;
    
    NSArray * cellarDoorOpenTimes = [object.openHoursSet sortedArrayUsingDescriptors:[WHOpenTimeMO sortDescriptors]];
    [cellarDoorOpenTimes enumerateObjectsUsingBlock:^(WHOpenTimeMO * openTime, NSUInteger idx, BOOL *stop) {
        BOOL isWeekday = (openTime.day.intValue > 0 && openTime.day.intValue <= 7);
        NSMutableArray * lastLineArray = [openTimesLineArray lastObject];
        if (lastLineArray != nil && isWeekday == YES) {
            WHOpenTimeMO * lastLineLastObject = [lastLineArray lastObject];
            int  absDifference     = abs(openTime.day.integerValue - lastLineLastObject.day.integerValue);
            BOOL isNeighbouringDay = (absDifference == 1 || absDifference == 6);
            if ([lastLineLastObject.openTime  isEqual:openTime.openTime] &&
                [lastLineLastObject.closeTime isEqual:openTime.closeTime] &&
                isNeighbouringDay == YES) {
                [lastLineArray addObject:openTime];
            } else {
                //New line
                [openTimesLineArray addObject:@[openTime].mutableCopy];
            }
        } else {
            //New line
            [openTimesLineArray addObject:@[openTime].mutableCopy];
        }
    }];
    
    //Second sort needed?
    
    __block NSMutableAttributedString * openingHoursAttributedString = [[NSMutableAttributedString alloc] init];;
    [openingHoursAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"Opening Hours: \n\n"]];
    
    [openTimesLineArray enumerateObjectsUsingBlock:^(NSArray * openTimesLineArray, NSUInteger idx, BOOL *stop) {
        NSString * openTimeString = [NSString new];
        WHOpenTimeMO * startOpen = [openTimesLineArray firstObject];
        WHOpenTimeMO * endOpen   = [openTimesLineArray lastObject];
        
        if ([startOpen isEqual:endOpen]) {
            if (startOpen.date != nil) {
                [dateFormatter setDateFormat:@"d MMM"];
                openTimeString = [openTimeString stringByAppendingString:[dateFormatter stringFromDate:startOpen.date]];
            } else {
                if (startOpen.day.integerValue == WHByAppointment && openTimesLineArray.count > 1) {
                    openTimeString = [openTimeString stringByAppendingString:@"\n"];
                }
                openTimeString = [openTimeString stringByAppendingString:wh_cellarOpenTimeString(startOpen.day.intValue)];
            }
        } else {
            NSArray * days = [openTimesLineArray valueForKey:@"day"];
            if([days isEqualToArray:@[@1,@2,@3,@4,@5,@6,@7]]) {
                openTimeString = [openTimeString stringByAppendingString:wh_cellarOpenTimeString(0)];
            } else {
                openTimeString = [openTimeString stringByAppendingString:wh_cellarOpenTimeString(startOpen.day.intValue)];
                openTimeString = [openTimeString stringByAppendingString:@" - "];
                openTimeString = [openTimeString stringByAppendingString:wh_cellarOpenTimeString(endOpen.day.intValue)];
            }
        }
        if (startOpen.day.integerValue != WHByAppointment) {
            [dateFormatter setDateFormat:@"h:mm a"];
            openTimeString = [openTimeString stringByAppendingString:@":\t"];
            openTimeString = [openTimeString stringByAppendingString:[dateFormatter stringFromDate:startOpen.openTime]];
            openTimeString = [openTimeString stringByAppendingString:@" - "];
            openTimeString = [openTimeString stringByAppendingString:[dateFormatter stringFromDate:endOpen.closeTime]];
            
        } else {
            if (object.phoneNumber.length > 0) {
                openTimeString = [openTimeString stringByAppendingString:[NSString stringWithFormat:@": %@",object.phoneNumber]];
            }
        }
        
        openTimeString = [openTimeString stringByAppendingString:@"\n"];
        NSAttributedString * openTimeAttributedString = [[NSAttributedString alloc] initWithString:openTimeString];
        [openingHoursAttributedString appendAttributedString:openTimeAttributedString];
    }];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setFirstLineHeadIndent:0];
    [paragraphStyle setHeadIndent:0.0];
    [paragraphStyle setLineSpacing:2.0];
    [paragraphStyle setTabStops:@[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft location:150 options:nil]]];

    //Set the font & colour attributes here?
    
    [openingHoursAttributedString addAttribute:NSParagraphStyleAttributeName
                                         value:paragraphStyle
                                         range:NSMakeRange(0, openingHoursAttributedString.length)];
    [openingHoursAttributedString addAttribute:NSFontAttributeName
                                         value:[UIFont edmondsansRegularOfSize:14.0]
                                         range:NSMakeRange(0, openingHoursAttributedString.length)];
    [openingHoursAttributedString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor wh_grey]
                                         range:NSMakeRange(0, openingHoursAttributedString.length)];
    
    return openingHoursAttributedString;
}

@end