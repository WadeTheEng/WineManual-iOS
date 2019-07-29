//
//  WHWineClubCell.h
//  WineHound
//
//  Created by Mark Turner on 12/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHWineClubMO;
@protocol WHWineClubCellDelegate;

@interface WHWineClubCell : UITableViewCell
@property (nonatomic,weak) WHWineClubMO * wineClub;
@property (nonatomic,weak) id <WHWineClubCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForWineClubObject:(WHWineClubMO *)wineClub;

@end

@protocol WHWineClubCellDelegate <NSObject>
- (void)wineClubCell:(WHWineClubCell*)cell didTapWebsiteButton:(UIButton *)button;
- (void)wineClubCell:(WHWineClubCell*)cell didTapURL:(NSURL *)url;
@end