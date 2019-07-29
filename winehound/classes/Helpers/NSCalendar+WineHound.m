//
//  NSCalendar+WineHound.m
//  WineHound
//
//  Created by Mark Turner on 23/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSCalendar+WineHound.h"

static NSCalendar * _publicCalendar;

@implementation NSCalendar (WineHound)

+ (NSCalendar *)wh_sharedCalendar
{
    //Shouldn't be nessasary to dispatch once
    if (_publicCalendar == nil) {
        NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [calendar setLocale:[NSLocale localeWithLocaleIdentifier:@"en_AU"]];
        _publicCalendar = calendar;
    }
    return _publicCalendar;
}

@end
