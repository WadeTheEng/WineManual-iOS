//
//  WHEventsTableCell.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class    WHEventMO;
@protocol WHEventsTableCellDataSource;
@protocol WHEventsTableCellDelegate;

@interface WHEventsTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView        *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel                 *noEventsLabel;

@property (nonatomic,weak) id <WHEventsTableCellDataSource> dataSource;
@property (nonatomic,weak) id <WHEventsTableCellDelegate>   delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeight;
+ (CGFloat)featuredCellHeight;

- (void)reload;

@end

@protocol WHEventsTableCellDataSource <NSObject>
- (NSInteger)numberOfEventsInEventsCell:(WHEventsTableCell *)eventsCell;
- (WHEventMO *)eventsCell:(WHEventsTableCell *)eventsCell eventObjectForIndex:(NSInteger)index;
@end

@protocol WHEventsTableCellDelegate <NSObject>
- (void)eventsCell:(WHEventsTableCell *)eventsCell didSelectEventAtIndex:(NSInteger)index;
@end