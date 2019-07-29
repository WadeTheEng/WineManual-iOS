//
//  WHWineCarouselCell.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class    iCarousel;
@protocol WHWineCarouselCellDataSource;
@protocol WHWineCarouselCellDelegate;

@interface WHWineCarouselCell : UITableViewCell
@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

@property (nonatomic,weak) id <WHWineCarouselCellDataSource> dataSource;
@property (nonatomic,weak) id <WHWineCarouselCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;

- (void)reload;
- (void)scrollToWineAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

@class WHWineMO;
@protocol WHWineCarouselCellDataSource <NSObject>
- (NSUInteger)numberOfWineObjectsInCell:(WHWineCarouselCell *)cell;
- (WHWineMO *)cell:(WHWineCarouselCell *)cell wineObjectAtIndex:(NSUInteger)index;
@end

@protocol WHWineCarouselCellDelegate <NSObject>
- (void)cell:(WHWineCarouselCell *)cell currentWineIndexDidChange:(NSInteger)currentItemIndex;
@end