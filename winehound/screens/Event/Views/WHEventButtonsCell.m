//
//  WHEventButtonsCell.m
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHEventButtonsCell.h"

#import "UIFont+Edmondsans.h"
#import "UIButton+WineHoundButtons.h"

@implementation WHEventButtonsCell

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_websiteButton.titleLabel  setFont:[UIFont edmondsansRegularOfSize:_websiteButton.titleLabel.font.pointSize]];
    [_calendarButton.titleLabel setFont:[UIFont edmondsansRegularOfSize:_calendarButton.titleLabel.font.pointSize]];

    [_websiteButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    [_calendarButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    
    [_websiteButton  addTarget:self action:@selector(_websiteButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_calendarButton addTarget:self action:@selector(_calendarButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [_websiteButton setImage:[UIImage imageNamed:@"event_view_website_icon"] forState:UIControlStateNormal];
    [_calendarButton setImage:[UIImage imageNamed:@"event_calendar_icon"] forState:UIControlStateNormal];
}

#pragma mark

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [self.class reuseIdentifier];
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self reuseIdentifier] bundle:[NSBundle mainBundle]];
}

+ (CGFloat)cellHeight
{
    return 60.0;
}

#pragma mark Actions

- (void)_websiteButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(eventButtonCell:didTapWebsiteButton:)]) {
        [self.delegate eventButtonCell:self didTapWebsiteButton:button];
    }
}

- (void)_calendarButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(eventButtonCell:didTapCalendarButton:)]) {
        [self.delegate eventButtonCell:self didTapCalendarButton:button];
    }
}

@end
