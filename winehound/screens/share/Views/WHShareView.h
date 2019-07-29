//
//  WHShareWinery.h
//  WineHound
//
//  Created by Mark Turner on 16/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHShareProtocol.h"

@protocol WHShareAlertDelegate;
@interface WHShareView : UIView
{
    __weak IBOutlet UILabel *_titleLabel;
    
    __weak IBOutlet UIButton *_facebookButton;
    __weak IBOutlet UIButton *_twitterButton;
    __weak IBOutlet UIButton *_emailButton;
    __weak IBOutlet UIButton *_smsButton;
}

@property (nonatomic,weak) id <WHShareAlertDelegate> delegate;
@property (nonatomic,weak) id <WHShareProtocol> object;

- (void)setTitle:(NSString *)title;

@end

@protocol WHShareAlertDelegate <NSObject>
- (void)shareView:(WHShareView *)view didTapFacebookButton:(UIButton *)button;
- (void)shareView:(WHShareView *)view didTapTwitterButton:(UIButton *)button;
- (void)shareView:(WHShareView *)view didTapEmailButton:(UIButton *)button;
- (void)shareView:(WHShareView *)view didTapSMSButton:(UIButton *)button;
@end