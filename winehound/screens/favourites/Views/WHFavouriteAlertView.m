//
//  WHFavouriteAlertView.m
//  WineHound
//
//  Created by Mark Turner on 16/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHFavouriteAlertView.h"

#import "UIButton+WineHoundButtons.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@interface WHFavouriteAlertView () <UITextFieldDelegate>
{
    NSLayoutConstraint __weak * _heightLayoutConstraint;
    
    UIView __weak      * _textFieldTopStroke;
    UIView __weak      * _textFieldBottomStroke;
    UITextField __weak * _textField;
}
@end

@implementation WHFavouriteAlertView
@dynamic textField;

+ (id)new
{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHFavouriteAlertView" owner:nil options:nil];
    return [views firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_titleLabel setFont:[UIFont edmondsansBoldOfSize:18.0]];
    [_titleLabel setTextColor:[UIColor wh_burgundy]];

    [_detailLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [_detailLabel setTextColor:[UIColor wh_grey]];
    
    [_favouriteButton setBackgroundColor:[UIColor clearColor]];
    [_favouriteButton setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [_favouriteButton.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [_favouriteButton addTarget:self action:@selector(_favouriteButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_favouriteButton setupButtonWithColour:[UIColor wh_burgundy]
                                borderWidth:1.0
                               cornerRadius:2.0];
    
    NSAttributedString * optOutAttributedString =
    [[NSAttributedString alloc] initWithString:@"Opt out from mailing list"
                                    attributes:@{NSFontAttributeName            : [UIFont edmondsansMediumOfSize:14.0],
                                                 NSForegroundColorAttributeName : [UIColor wh_burgundy],
                                                 NSUnderlineStyleAttributeName  : @(NSUnderlineStyleSingle)}];

    [_optOutButton setAttributedTitle:optOutAttributedString forState:UIControlStateNormal];
    [_optOutButton addTarget:self action:@selector(_optOutButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:195.0];
    
    [self addConstraint:heightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:260.0]];
    
    _heightLayoutConstraint = heightConstraint;
}

- (UITextField *)textField
{
    return _textField;
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    /*
     Calculate height required & update _heightLayoutConstraint...?
     */
}

- (void)layoutSubviews
{
    NSLog(@"%s", __func__);
    [super layoutSubviews];
    
    [_textFieldTopStroke    setFrame:CGRectMake(.0, CGRectGetMinY(_textField.frame),     CGRectGetWidth(self.bounds), 1.0)];
    [_textFieldBottomStroke setFrame:CGRectMake(.0, CGRectGetMaxY(_textField.frame)-1.0, CGRectGetWidth(self.bounds), 1.0)];
}

#pragma mark

- (void)_favouriteButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(favouriteAlertView:didTapFavouriteButton:)]) {
        [self.delegate favouriteAlertView:self didTapFavouriteButton:button];
    }
}

- (void)_optOutButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(favouriteAlertView:didTapOptOutButton:)]) {
        [self.delegate favouriteAlertView:self didTapOptOutButton:button];
    }
}

#pragma mark 

- (void)displayEmailEntry
{
    [_heightLayoutConstraint setConstant:220.0];
    
    [_detailLabel setText:@"Add your email address to hear all about this winery's news and events."];
    
    UITextField * textField = [UITextField new];
    [textField setFrame:CGRectMake(20.0, 120.0, CGRectGetWidth(self.bounds) - 40.0, 30.0)];
    [textField setDelegate:self];
    [textField setPlaceholder:@"Email Address"];
    [textField setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [textField setTextColor:[UIColor wh_grey]];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    [self addSubview:textField];
    _textField = textField;
    
    UIView * topStroke = [UIView new];
    [topStroke setFrame:CGRectMake(.0, textField.frame.origin.y, CGRectGetWidth(self.bounds), 1.0)];
    [topStroke setBackgroundColor:[UIColor wh_grey]];
    [self addSubview:topStroke];
    _textFieldTopStroke = topStroke;

    UIView * bottomStroke = [UIView new];
    [bottomStroke setFrame:CGRectMake(.0, CGRectGetMaxY(textField.frame), CGRectGetWidth(self.bounds), 1.0)];
    [bottomStroke setBackgroundColor:[UIColor wh_grey]];
    [self addSubview:bottomStroke];
    _textFieldBottomStroke = bottomStroke;
    
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textField addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:36.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_detailLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:10.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:20.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:textField
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:20.0]];
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

@end
