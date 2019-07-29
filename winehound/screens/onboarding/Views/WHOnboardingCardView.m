//
//  WHOnboardingCardView.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHOnboardingCardView.h"
#import "UIFont+Edmondsans.h"

@interface WHOnboardingCardView ()
{
    __weak IBOutlet UILabel     *_titleLabel;
    __weak IBOutlet UILabel     *_detailLabel;
    __weak IBOutlet UIImageView *_iconImageVIew;

    __weak IBOutlet UIView      *_backgroundView;
}
@end

@implementation WHOnboardingCardView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_titleLabel setFont:[UIFont edmondsansBoldOfSize:26.0]];
    [_detailLabel setFont:[UIFont edmondsansRegularOfSize:16.0]];

    [_backgroundView.layer setCornerRadius:10.0];
    [_backgroundView.layer setMasksToBounds:YES];
}

- (void)setTitle:(NSString *)title detail:(NSString *)detail icon:(UIImage *)icon
{
    [_titleLabel setText:title];
    [_detailLabel setText:detail];
    [_iconImageVIew setImage:icon];
}

@end
