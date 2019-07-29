//
//  NSPredicate+Date.m
//  WineHound
//
//  Created by Mark Turner on 22/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSPredicate+Date.h"
#import "NSCalendar+WineHound.h"

@implementation NSPredicate (Date)

+ (NSPredicate *)predicateForDate:(NSDate *)date
{
    NSCalendar * calendar = [NSCalendar currentCalendar];

    NSDateComponents *components = [[NSCalendar wh_sharedCalendar] components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    
    NSDate * lastMidnight = [calendar dateFromComponents:components];
    NSDate * nextMidnight = [lastMidnight dateByAddingTimeInterval:(24*3600)];
    
    //MT Review
    return [NSPredicate predicateWithFormat:@"(%@ >= startDate AND %@ <= finishDate) || (%@ >= startDate AND %@ <= finishDate)",lastMidnight,lastMidnight,nextMidnight,nextMidnight];
}

+ (NSPredicate *)predicateForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    return [NSPredicate predicateWithFormat:@"(startDate >= %@ AND startDate <= %@) || (finishDate >= %@ AND finishDate <= %@)",startDate,endDate,startDate,endDate];
}

@end
