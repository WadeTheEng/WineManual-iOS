//
//  WHFavouriteAlertView.h
//  WineHound
//
//  Created by Mark Turner on 16/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHFavouriteAlertViewDelegate;
@interface WHFavouriteAlertView : UIView
{
    __weak IBOutlet UILabel  *_titleLabel;
    __weak IBOutlet UILabel  *_detailLabel;
    __weak IBOutlet UIButton *_favouriteButton;
    __weak IBOutlet UIButton *_optOutButton;
}

@property (nonatomic,readonly) UITextField * textField;
@property (nonatomic,weak) id <WHFavouriteAlertViewDelegate> delegate;

- (void)displayEmailEntry;

@end

@protocol WHFavouriteAlertViewDelegate <NSObject>
- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapOptOutButton:(UIButton *)button;
- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapFavouriteButton:(UIButton *)button;
@end