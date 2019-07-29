//
//  WHWineDescriptionCell.h
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHWineMO;
@protocol WHWineDescriptionCellDelegate;

@interface WHWineDescriptionCell : UITableViewCell
{
    __weak IBOutlet UILabel  *_wineTitleLabel;
    __weak IBOutlet UITextView  *_wineDescriptionTextView;
    __weak IBOutlet UIButton *_favouriteButton;
}
+ (CGFloat)cellHeightForWineObject:(WHWineMO *)wine;
+ (NSString *)reuseIdentifier;

@property (nonatomic,weak) WHWineMO * wine;
@property (nonatomic,readonly) UIButton * favouriteButton;
@property (nonatomic,weak) id <WHWineDescriptionCellDelegate> delegate;

@end

@protocol WHWineDescriptionCellDelegate <NSObject>
- (void)wineDescriptionCell:(WHWineDescriptionCell *)cell didTapFavouriteButton:(UIButton *)button;
- (void)wineDescriptionCell:(WHWineDescriptionCell *)cell didTapURL:(NSURL *)url;
@end