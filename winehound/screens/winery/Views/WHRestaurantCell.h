//
//  WHRestaurantCell.h
//  WineHound
//
//  Created by Mark Turner on 20/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHRestaurantMO;
@protocol WHRestaurantCellDelegate;

@interface WHRestaurantCell : UITableViewCell

@property (nonatomic,weak) WHRestaurantMO * restaurant;
@property (nonatomic,weak) id <WHRestaurantCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForRestaurantObject:(WHRestaurantMO *)restaurant;

@end

@protocol WHRestaurantCellDelegate <NSObject>
- (void)restaurantCell:(WHRestaurantCell*)cell didTapViewMenuButton:(UIButton *)button;
- (void)restaurantCell:(WHRestaurantCell*)cell didTapURL:(NSURL *)url;
@end