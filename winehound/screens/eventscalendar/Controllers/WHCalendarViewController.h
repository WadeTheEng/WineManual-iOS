//
//  WHEventsCalendarViewController.h
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <V8HorizontalPickerView/V8HorizontalPickerViewProtocol.h>

/**
 *  Credit to Jerome Miglino - `PDTSimpleCalendarViewController`
 */

@class V8HorizontalPickerView;

@interface WHCalendarViewController : UIViewController <V8HorizontalPickerViewDelegate>
{
    NSInteger _currentMonth;
    NSDate *  _selectedDate;
}

@property (weak, nonatomic) IBOutlet V8HorizontalPickerView *monthHorizontalPickerView;

@property (weak, nonatomic) IBOutlet UICollectionView *datePickerCollectionView;

/**
 *  The calendar used to generate the view.
 *
 *  If not set, the default value is `[NSCalendar currentCalendar]`
 */
@property (nonatomic, strong) NSCalendar *calendar;

/**
 *  Selected date displayed by the calendar.
 *  Changing this value will cause the calendar to scroll to this date (without animation).
 */
@property (nonatomic, strong) NSDate *selectedDate;

/**
 *  Index of the current month to display.
 */
@property (nonatomic) NSInteger currentMonth;
@property (nonatomic) NSInteger monthOffset;

@property (nonatomic, readonly) NSDate *firstDate;
@property (nonatomic, readonly) NSDate *firstOfMonth;
@property (nonatomic, readonly) NSDate *lastOfMonth;

/**
 *  Change the selected date of the calendar, and scroll to it
 *
 *  @param newSelectedDate the date that will be selected
 *  @param animated        if you wanna animate the scrolling
 */
- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated;

- (BOOL)cellIndicatorVisibleForDate:(NSDate *)date;

- (void)updateMonth;

@end
