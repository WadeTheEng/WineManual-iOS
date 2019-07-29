//
//  WHEventCalendarViewCell.h
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHEventCalendarViewCell : UICollectionViewCell

/**
 *  Define if the cell is today in the calendar.
 */
@property (nonatomic, assign) BOOL isToday;

/**
 *  Set the day number to display for the cell
 *
 *  @param dayNumber from 1 to 31.
 */
- (void)setDayNumber:(NSString *)dayNumber;

- (void)setIndicatorVisible:(BOOL)visible;

+ (NSString *)reuseIdentifier;

@end
