//
//  WHShareWinery.m
//  WineHound
//
//  Created by Mark Turner on 16/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHShareView.h"

#import "UIButton+WineHoundButtons.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation WHShareView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_titleLabel setFont:[UIFont edmondsansBoldOfSize:18.0]];
    [_titleLabel setTextColor:[UIColor wh_burgundy]];
    
    [_facebookButton setupButtonWithColour:[UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:153.0/255.0 alpha:1.0]
                               borderWidth:1.0
                              cornerRadius:2.0];
    [_twitterButton  setupButtonWithColour:[UIColor colorWithRed:85.0/255.0 green:172.0/255.0 blue:238.0/255.0 alpha:1.0]
                               borderWidth:1.0
                              cornerRadius:2.0];
    [_emailButton    setupButtonWithColour:[UIColor wh_burgundy]
                               borderWidth:1.0
                              cornerRadius:2.0];
    [_smsButton      setupButtonWithColour:[UIColor wh_burgundy]
                               borderWidth:1.0
                              cornerRadius:2.0];
    
    [_facebookButton setBackgroundColor:[UIColor clearColor]];
    [_twitterButton  setBackgroundColor:[UIColor clearColor]];
    [_emailButton    setBackgroundColor:[UIColor clearColor]];
    [_smsButton      setBackgroundColor:[UIColor clearColor]];
    
    [_facebookButton setTitleColor:[UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_twitterButton  setTitleColor:[UIColor colorWithRed:85.0/255.0 green:172.0/255.0 blue:238.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_emailButton    setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [_smsButton      setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    
    [_facebookButton.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [_twitterButton.titleLabel  setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [_emailButton.titleLabel    setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [_smsButton.titleLabel      setFont:[UIFont edmondsansBoldOfSize:14.0]];
    
    [_facebookButton addTarget:self action:@selector(_facebookButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_twitterButton  addTarget:self action:@selector(_twitterButtonTouchedUpInside:)  forControlEvents:UIControlEventTouchUpInside];
    [_emailButton    addTarget:self action:@selector(_emailButtonTouchedUpInside:)    forControlEvents:UIControlEventTouchUpInside];
    [_smsButton      addTarget:self action:@selector(_smsButtonTouchedUpInside:)      forControlEvents:UIControlEventTouchUpInside];
}

- (void)setTitle:(NSString *)title
{
    [_titleLabel setText:title];
}

- (void)setObject:(id<WHShareProtocol>)object
{
    NSAssert([object conformsToProtocol:@protocol(WHShareProtocol)], @"Object does not conform to WHShareProtocol");
    _object = object;
}

#pragma mark 
#pragma mark Actions

- (void)_facebookButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(shareView:didTapFacebookButton:)]) {
        [self.delegate shareView:self didTapFacebookButton:button];
    }
}

- (void)_twitterButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(shareView:didTapTwitterButton:)]) {
        [self.delegate shareView:self didTapTwitterButton:button];
    }
}

- (void)_emailButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(shareView:didTapEmailButton:)]) {
        [self.delegate shareView:self didTapEmailButton:button];
    }
}

- (void)_smsButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(shareView:didTapSMSButton:)]) {
        [self.delegate shareView:self didTapSMSButton:button];
    }
}

@end
