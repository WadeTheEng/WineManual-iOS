//
//  WHWineClubCell.m
//  WineHound
//
//  Created by Mark Turner on 12/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHWineClubCell.h"
#import "WHWineClubMO.h"

#import "UIButton+WineHoundButtons.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "NSAttributedString+HTML.h"

@interface WHWineClubCell () <UITextViewDelegate>
{
    __weak IBOutlet UITextView *_descriptionTextView;
    __weak IBOutlet UIButton   *_viewWebsiteButton;
}
@end

@implementation WHWineClubCell

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

+ (CGFloat)cellHeightForWineClubObject:(WHWineClubMO *)wineClub
{
    NSAttributedString * attributedString = [NSAttributedString wh_attributedStringWithHTMLString:wineClub.clubDescription];
    CGRect requiredRect = [attributedString boundingRectWithSize:(CGSize){300.0, CGFLOAT_MAX}
                                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                         context:nil];
    return 10.0 + ceilf(requiredRect.size.height) + 20.0 + 44.0 + 30.0; //magic numbers correspond to XIB constraints.
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
 
    [_descriptionTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    [_descriptionTextView setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [_descriptionTextView setTextColor:[UIColor wh_grey]];
    [_descriptionTextView setText:nil];
    [_descriptionTextView setDataDetectorTypes:UIDataDetectorTypeAll];
    [_descriptionTextView setEditable:NO];
    [_descriptionTextView setSelectable:YES];
    [_descriptionTextView setScrollEnabled:NO];
    [_descriptionTextView setDelegate:self];
    
    [_viewWebsiteButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    [_viewWebsiteButton setBackgroundColor:[UIColor whiteColor]];
    [_viewWebsiteButton addTarget:self action:@selector(_viewWebsiteButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_viewWebsiteButton setImage:[UIImage imageNamed:@"wineclub_website_icon"] forState:UIControlStateNormal];
}

- (void)setWineClub:(WHWineClubMO *)wineClub
{
    _wineClub = wineClub;
    
    [_descriptionTextView setAttributedText:[NSAttributedString wh_attributedStringWithHTMLString:_wineClub.clubDescription]];
    [_viewWebsiteButton setHidden:!(_wineClub.website.length > 0)];
}

- (void)_viewWebsiteButtonTouchedUpInside:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(wineClubCell:didTapWebsiteButton:)]) {
        [self.delegate wineClubCell:self didTapWebsiteButton:button];
    }
}

#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    if ([self.delegate respondsToSelector:@selector(wineClubCell:didTapURL:)]) {
        [self.delegate wineClubCell:self didTapURL:URL];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}


@end
