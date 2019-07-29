//
//  NSPredicate+Date.h
//  WineHound
//
//  Created by Mark Turner on 22/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (Date)

/*
 Returns a predicate for fetching managed objects that occur on a particular date.
 The managed object entity must have two attributes startTime/finishTime.
 */
+ (NSPredicate *)predicateForDate:(NSDate *)date;

/*
 Returns a predicate for fetching managed objects that occur between two provided dates.
 The managed object entity must have two attributes startTime/finishTime.
 */
+ (NSPredicate *)predicateForStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
