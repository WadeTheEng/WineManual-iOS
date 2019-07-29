//
//  WHWineCell.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class     WHWineMO;
@protocol  WHWineCellDelegate;

@interface WHWineCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bottleImageView;
@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton    *favouriteButton;

@property (nonatomic,weak) UIActivityIndicatorView * activityIndicatorView;

@property (nonatomic,weak) WHWineMO * wine;
@property (nonatomic,weak) id <WHWineCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeight;

@end

@protocol WHWineCellDelegate <NSObject>
- (void)wineCell:(WHWineCell *)wineCell didTapFavouriteButton:(UIButton *)button;
@end
