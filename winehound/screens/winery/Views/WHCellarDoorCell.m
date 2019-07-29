//
//  WHCellarDoorCell.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHCellarDoorCell.h"
#import "WHWineryMO+Additions.h"
#import "WHHelpers.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

#import "NSAttributedString+HTML.h"
#import "NSAttributedString+OpenHours.h"

@interface WHCellarDoorCell () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTextViewHeightConstraint;
@end

@implementation WHCellarDoorCell

#pragma mark

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self reuseIdentifier] bundle:[NSBundle mainBundle]];
}

#pragma mark

+ (CGFloat)cellHeightForWineryObject:(WHWineryMO *)winery
{
    return [self cellHeightForWineryObject:winery truncated:YES];
}

+ (CGFloat)cellHeightForWineryObject:(WHWineryMO *)winery truncated:(BOOL)truncated
{
    const CGFloat kBottomPadding = 25.0;
    
    NSString * htmlString = truncated?TruncatedString(winery.cellarDoorDescription,350):winery.cellarDoorDescription;
    
    NSAttributedString * attributedString = [NSAttributedString wh_attributedStringWithHTMLString:htmlString];
    CGRect requiredBoundingRect = [attributedString
                                   boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                   context:nil];
    
    CGFloat requiredHeight = 15.0 + requiredBoundingRect.size.height;
    if (winery.openHoursSet.count > 0) {
        /*
         boundingRectWithSize does not appear to work on 'openHoursAttributedStringWithObject'
         But since no wrapping occurs, we're fine to use NSAttributedString's size property.
         */
        CGSize openHoursSizeRequired = [[NSAttributedString openHoursAttributedStringWithObject:winery] size];
        requiredHeight += openHoursSizeRequired.height;
        requiredHeight += 15.0;//extra padding
    }
    return ceilf(5.0 + requiredHeight + kBottomPadding);
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.cellarDoorInfoTextView    setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [self.openingHoursTextView         setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [self.readMoreButton.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    
    [self.readMoreButton      setTitleColor:[UIColor wh_burgundy] forState:UIControlStateNormal];
    [self.openingHoursTextView   setTextColor:[UIColor wh_grey]];
    [self.cellarDoorInfoTextView setTextColor:[UIColor wh_grey]];
    [self.readMoreButton addTarget:self action:@selector(_cellarDoorButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.activityIndicatorView setHidesWhenStopped:YES];
    
    [self.cellarDoorInfoTextView setScrollEnabled:NO];
    [self.cellarDoorInfoTextView setSelectable:YES];
    [self.cellarDoorInfoTextView setEditable:NO];
    [self.cellarDoorInfoTextView setDelegate:self];
    [self.cellarDoorInfoTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    
    [self.openingHoursTextView setDataDetectorTypes:UIDataDetectorTypePhoneNumber];
    [self.openingHoursTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    [self.openingHoursTextView setSelectable:YES];
    [self.openingHoursTextView setEditable:NO];
    [self.openingHoursTextView setScrollEnabled:NO];
    
    [self.infoTextViewHeightConstraint setConstant:0];
}

- (void)setCellarDoorText:(NSString *)string
{
    [self setCellarDoorText:string truncated:YES];
}

- (void)setCellarDoorText:(NSString *)string truncated:(BOOL)truncated
{
    NSString * htmlString = truncated?TruncatedString(string,350):string;
    NSAttributedString * shortAttributedString = [NSAttributedString wh_attributedStringWithHTMLString:htmlString];
    CGRect requiredBoundingRect = [shortAttributedString
                                   boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                   context:nil];
    [self.cellarDoorInfoTextView setAttributedText:shortAttributedString];

    [self.infoTextViewHeightConstraint setConstant:ceilf(requiredBoundingRect.size.height)];
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
}

- (void)setOpeningHoursString:(NSAttributedString *)attrString
{
    /*
     No need to update constraint as 'cellHeightForWineryObject' + updating 'infoTextViewHeightConstraint'
     will result in correct height.
     */
    [self.openingHoursTextView setAttributedText:attrString];
}

#pragma mark -

- (void)_cellarDoorButtonTouchedUpInside:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellarDoorCell:didSelectReadMoreButton:)]) {
        [self.delegate cellarDoorCell:self didSelectReadMoreButton:button];
    }
}
#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(cellarDoorCell:didTapURL:)]) {
        [self.delegate cellarDoorCell:self didTapURL:URL];
        return NO;
    } else {
        return YES;
    }
}

@end
