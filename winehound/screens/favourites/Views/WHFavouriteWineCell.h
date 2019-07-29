//
//  WHFavouriteWineCell.h
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>

@class WHWineMO;
@interface WHFavouriteWineCell : SWTableViewCell
{
    __weak IBOutlet UIImageView *_wineImageView;
    __weak IBOutlet UILabel     *_wineTitleLabel;
    __weak IBOutlet UILabel     *_wineDescriptionLabel;
}
@property (nonatomic,weak) WHWineMO * wine;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end
