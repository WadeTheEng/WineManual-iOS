//
//  WHEventsCalendarViewController.m
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <V8HorizontalPickerView/V8HorizontalPickerView.h>

#import "WHCalendarViewController.h"
#import "WHEventCalendarViewCell.h"
#import "WHCalendarHeaderView.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@interface WHCalendarViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic,readonly) NSArray * monthSymbols;

@end

@implementation WHCalendarViewController
@synthesize currentMonth = _currentMonth;
@synthesize selectedDate = _selectedDate;
@synthesize monthSymbols = _monthSymbols;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _monthOffset = NSNotFound;
}

#pragma mark
#pragma mark

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.monthHorizontalPickerView setDelegate:(id)self];
    [self.monthHorizontalPickerView setDataSource:(id)self];
    [self.monthHorizontalPickerView setBackgroundColor:[UIColor wh_burgundy]];
    
    //Configure the Collection View
    [self.datePickerCollectionView setDataSource:self];
    [self.datePickerCollectionView setDelegate:self];

    [self.datePickerCollectionView registerClass:[WHEventCalendarViewCell class] forCellWithReuseIdentifier:[WHEventCalendarViewCell reuseIdentifier]];
    [self.datePickerCollectionView registerNib:[UINib nibWithNibName:@"WHCalendarHeaderView" bundle:[NSBundle mainBundle]]
                    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                           withReuseIdentifier:[WHCalendarHeaderView reuseIdentifier]];
    
    [self.datePickerCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    UICollectionViewFlowLayout * flowLayout = [UICollectionViewFlowLayout new];
    [flowLayout setMinimumInteritemSpacing:4.0];
    [flowLayout setMinimumLineSpacing:0.0];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0.0, 28.0, 0.0, 28.0)];
    [flowLayout setHeaderReferenceSize:CGSizeMake(0, 45.0)];
    [flowLayout setItemSize:CGSizeMake(34.0, 34.0)];
    [self.datePickerCollectionView setCollectionViewLayout:flowLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.monthHorizontalPickerView setSelectionPoint:CGPointMake(CGRectGetWidth(self.monthHorizontalPickerView.bounds)*.5, 0)];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [UIView setAnimationsEnabled:NO];
    //Sets here due to V8HorizontalPickerView bug.
    UIImageView * selectionIndicatorIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"events_month_indicator"]];
    [self.monthHorizontalPickerView setSelectionPoint:CGPointMake(CGRectGetWidth(self.monthHorizontalPickerView.bounds)*.5, 0)];
    [self.monthHorizontalPickerView setSelectionIndicatorView:selectionIndicatorIV];
    [UIView setAnimationsEnabled:YES];
    
    [self.view layoutSubviews];
}

#pragma mark
#pragma mark - Accessors

- (NSCalendar *)calendar
{
    if (_calendar == nil) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [NSDateFormatter new];
    }
    return _dateFormatter;
}

- (NSArray *)monthSymbols
{
    if (_monthSymbols == nil) {
        NSInteger currentMonthIndex = [self monthOffset];
        
        NSArray * monthSymbols = [self.dateFormatter monthSymbols];
        NSArray * firstArray  = [monthSymbols subarrayWithRange:NSMakeRange(currentMonthIndex, monthSymbols.count - currentMonthIndex)];
        NSArray * secondArray = [monthSymbols subarrayWithRange:NSMakeRange(0,currentMonthIndex)];
        NSArray * reorderedMonthSymbols = [firstArray arrayByAddingObjectsFromArray:secondArray];

        _monthSymbols = reorderedMonthSymbols;
    }
    return _monthSymbols;
}

- (NSInteger)monthOffset
{
    if (_monthOffset == NSNotFound) {
        NSDateComponents * components = [self.calendar components:NSMonthCalendarUnit fromDate:[NSDate date]];
        _monthOffset = components.month-1;
    }
    return _monthOffset;
}

- (void)setSelectedDate:(NSDate *)newSelectedDate
{
    [self setSelectedDate:newSelectedDate animated:NO];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated
{
    //Test if selectedDate between first & last date
    /*
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if (([startOfDay compare:self.firstDate] == NSOrderedAscending) || ([startOfDay compare:self.lastDate] == NSOrderedDescending)) {
        return;
    }*/
    
    [[self cellForItemAtDate:_selectedDate] setSelected:NO];
    [[self cellForItemAtDate:newSelectedDate] setSelected:YES];
    
    _selectedDate = newSelectedDate;

    if (newSelectedDate != nil) {
        NSIndexPath *indexPath = [self indexPathForCellAtDate:_selectedDate];
        [self.datePickerCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    } else {
        
        [[self.datePickerCollectionView indexPathsForSelectedItems] enumerateObjectsUsingBlock:^(NSIndexPath * selectedIndexPath, NSUInteger idx, BOOL *stop) {
            [self.datePickerCollectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
        }];
    }

    /*
    self.currentMonth = 0;
    */
}

/*
- (void)setCurrentMonth:(NSInteger)currentMonth
{
    _currentMonth = currentMonth;
    [self updateMonth];
}
 */

- (void)updateMonth
{
    [self.datePickerCollectionView reloadData];
}

- (BOOL)cellIndicatorVisibleForDate:(NSDate *)date
{
    return NO;
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *firstOfMonth = [self firstOfMonth];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
    
    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    return (rangeOfWeeks.length * 7);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventCalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[WHEventCalendarViewCell reuseIdentifier]
                                                                              forIndexPath:indexPath];
    
    NSDate *firstOfMonth = [self firstOfMonth];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];
    
    NSString *cellTitleString = @"";
    BOOL isToday = NO;
    BOOL isSelected = NO;
    
    [cell setIndicatorVisible:NO];
    
    if (cellDateComponents.month == firstOfMonthsComponents.month) {
        cellTitleString = [NSString stringWithFormat:@"%@", @(cellDateComponents.day)];
        isSelected = [self isSelectedDate:cellDate];
        isToday = [self isTodayDate:cellDate];
        
        if ([self respondsToSelector:@selector(cellIndicatorVisibleForDate:)]) {
            [cell setIndicatorVisible:[self cellIndicatorVisibleForDate:cellDate]];
        }
    }
    
    [cell setDayNumber:cellTitleString];
    [cell setIsToday:isToday];
    [cell setSelected:isSelected];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonth];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];
    
    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];
    
    return (cellDateComponents.month == firstOfMonthsComponents.month);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate * selectedDate = [self dateForCellAtIndexPath:indexPath];
    if (NO == [selectedDate isEqualToDate:self.selectedDate]) {
        self.selectedDate = [self dateForCellAtIndexPath:indexPath];
    } else {
        self.selectedDate = nil;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        WHCalendarHeaderView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                               withReuseIdentifier:[WHCalendarHeaderView reuseIdentifier]
                                                                                      forIndexPath:indexPath];
        return headerView;
    }
    return nil;
}

#pragma mark -
#pragma mark - Calendar calculations

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)isSelectedDate:(NSDate *)date
{
    if (!self.selectedDate) {
        return NO;
    }
    return [self clampAndCompareDate:date withReferenceDate:self.selectedDate];
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    
    return [refDate isEqualToDate:clampedDate];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstDate
{
    if (_firstDate == nil) {
        NSDateComponents * components = [self.calendar components:NSYearCalendarUnit fromDate:[NSDate date]];
        [components setMonth:1];
        NSDate * firstDate = [self.calendar dateFromComponents:components];
        _firstDate = firstDate;
    }
    return _firstDate;
}

- (NSDate *)firstOfMonth
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = self.currentMonth;
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (NSDate *)lastOfMonth
{
    NSDateComponents *offset = [NSDateComponents new];
    
    NSRange dayRange = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                           inUnit:NSMonthCalendarUnit
                                          forDate:self.firstOfMonth];
    offset.month = self.currentMonth;
    offset.day = dayRange.length;
    offset.minute = -1;
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonth];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;
    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}


- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSDate *firstOfMonth = [self firstOfMonth];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    
    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *firstOfMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstOfMonth];
    NSInteger item = (dateComponents.day - firstOfMonthComponents.day) - (1 - ordinalityOfFirstDay);
    
    return [NSIndexPath indexPathForItem:item inSection:0];
}

- (WHEventCalendarViewCell *)cellForItemAtDate:(NSDate *)date
{
    return (WHEventCalendarViewCell *)[self.datePickerCollectionView cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}

#pragma mark V8HorizontalPickerViewDataSource

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
    return 1 + [[self monthSymbols] count];
}

#pragma mark V8HorizontalPickerViewDelegate

- (UIView *)horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index
{
    UIButton * labelView = [UIButton new];
    [labelView setUserInteractionEnabled:NO];
    [labelView setFrame:CGRectMake(0, 0, 80.0, CGRectGetHeight(picker.bounds))];
    [labelView.titleLabel setFont:[UIFont edmondsansMediumOfSize:12.0]];
    [labelView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (index == 0) {
        //display nearby
        [labelView setTitle:@"Nearby" forState:UIControlStateNormal];
        [labelView setImage:[UIImage imageNamed:@"events_nearby_icon"] forState:UIControlStateNormal];
        [labelView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 15.0)];

    } else {
        NSString * monthSymbol = [self.monthSymbols objectAtIndex:index-1];
        
        [labelView setTitle:monthSymbol forState:UIControlStateNormal];
        [labelView sizeToFit];
    }
    return labelView;
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
    if (index != 0) {
        NSString * monthSymbol = [self.monthSymbols objectAtIndex:index-1];
        CGRect requiredWidth = [monthSymbol
                                boundingRectWithSize:CGSizeMake(80.0, CGFLOAT_MAX)
                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                attributes:@{NSFontAttributeName: [UIFont edmondsansMediumOfSize:12.0]}
                                context:nil];
        return ceilf(requiredWidth.size.width) + 35.0;
    }
    return 80.0;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
    NSLog(@"%s - %li", __func__,(long)index);
    
    self.currentMonth = (index-1)+self.monthOffset;
}

@end
