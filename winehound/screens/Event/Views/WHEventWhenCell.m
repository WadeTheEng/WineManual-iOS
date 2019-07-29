//
//  WHEventWhenCell.m
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHEventWhenCell.h"
#import "WHEventMO+Mapping.h"
#import "WHEventMO+Additions.h"
#import "WHRegionMO.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

#import "NSCalendar+WineHound.h"

@implementation WHEventWhenCell

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_whenLabel setFont:[UIFont edmondsansRegularOfSize:_whenLabel.font.pointSize]];
    [_dateLabel setFont:[UIFont edmondsansRegularOfSize:_dateLabel.font.pointSize]];
    [_timeLabel setFont:[UIFont edmondsansRegularOfSize:_timeLabel.font.pointSize]];
    [_whereLabel    setFont:[UIFont edmondsansRegularOfSize:_whereLabel.font.pointSize]];
    [_locationLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    
    [_whenLabel setTextColor:[UIColor wh_grey]];
    [_dateLabel setTextColor:[UIColor wh_grey]];
    [_timeLabel setTextColor:[UIColor wh_grey]];
    [_whereLabel setTextColor:[UIColor wh_grey]];
    [_locationLabel setTextColor:[UIColor wh_grey]];
    
    [self setEvent:nil];
}

#pragma mark 

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [self.class reuseIdentifier];
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self reuseIdentifier] bundle:[NSBundle mainBundle]];
}

+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event
{
    CGFloat cellHeight = 80.0;
    
    NSString * locationString = [self locationStringFromEvent:event];
    if (locationString.length > 0) {
        CGRect requiredLocationSize = [locationString
                                       boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:[UIFont edmondsansRegularOfSize:14.0]}
                                       context:nil];
        cellHeight += 24.0;//where label height
        cellHeight += ceilf(requiredLocationSize.size.height);
        cellHeight += 16.0;//bottom padding.
    }
    return cellHeight;
}

+ (NSString *)locationStringFromEvent:(WHEventMO *)event
{
    NSMutableString * locationString = [NSMutableString new];
    WHRegionMO * region = [event.regions anyObject];
    if (region != nil) {
        [locationString appendString:[region name]];
    } else {
        if (event.locationName.length > 0) {
            [locationString appendString:event.locationName];
        }
        if (event.address.length > 0) {
            unichar last = [event.address characterAtIndex:[event.address length] - 1];
            if (NO == [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:last]) {
                [locationString appendString:@"\n"];
            }
            [locationString appendString:event.address];
        }
    }
    return locationString;
}

#pragma mark

- (void)setEvent:(WHEventMO *)event
{
    _event = event;

    NSDateFormatter * dateFormatter = [NSDateFormatter new];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

    NSString * timeString = nil;
    if (event.startDate != nil && event.finishDate != nil) {
        [dateFormatter setDateFormat:@"h:mma"];
        
        timeString = [NSString new];
        timeString = [timeString stringByAppendingString:[dateFormatter stringFromDate:event.startDate]];
        timeString = [timeString stringByAppendingString:@" - "];
        timeString = [timeString stringByAppendingString:[dateFormatter stringFromDate:event.finishDate]];
    }
    
    /*
    [event setSharedDateFormatter:dateFormatter];
     */

    NSString * datePeriodString = event.datePeriodString;
    [_dateLabel setText:datePeriodString];
    [_timeLabel setText:timeString];
    [_whenLabel setHidden:(datePeriodString.length <= 0)];
    
    NSString * locationString = [self.class locationStringFromEvent:_event];
    [_locationLabel setText:locationString];
    [_whereLabel setHidden:(locationString.length <= 0)];
}

@end
