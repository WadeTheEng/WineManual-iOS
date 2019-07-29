//
//  WHEventInfoCell.m
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHEventInfoCell.h"
#import "WHEventMO.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "NSAttributedString+HTML.h"

@interface WHEventInfoCell () <UITextViewDelegate>
@end

@implementation WHEventInfoCell {
    __weak IBOutlet NSLayoutConstraint *_descriptionTextViewBottomConstraint;
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_descriptionTextView setTextColor:[UIColor wh_grey]];
    [_descriptionTextView setFont:[UIFont edmondsansRegularOfSize:17.0]];
    [_descriptionTextView setTextContainerInset:UIEdgeInsetsMake(.0, -5, 0, 0)];
    [_descriptionTextView setScrollEnabled:NO];
    [_descriptionTextView setSelectable:YES];
    [_descriptionTextView setEditable:NO];
    [_descriptionTextView setDelegate:self];
    [_descriptionTextView setDataDetectorTypes:UIDataDetectorTypeAll];
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

+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event
{
    CGRect requiredBoundingBox = [[self _infoStringWithEvent:event]
                                  boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  context:nil];
    
    CGFloat requiredHeight = .0f;
    requiredHeight += 20.0;//padding.
    requiredHeight += ceilf(requiredBoundingBox.size.height) + 5.0;
    return requiredHeight;
    
}

#pragma mark

+ (NSMutableAttributedString *)_infoStringWithEvent:(WHEventMO *)event
{
    NSMutableAttributedString * eventAttributedString = [[NSMutableAttributedString alloc]
                                                         initWithAttributedString:[NSAttributedString wh_attributedStringWithHTMLString:event.eventDescription]];
    if (event.priceDescription.length > 0) {
        NSString *priceDescription = [[event.priceDescription componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
        [eventAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [eventAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:priceDescription
                                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor wh_grey],
                                                                                                   NSFontAttributeName:[UIFont edmondsansRegularOfSize:14.0]}]];
    }
    if (event.phoneNumber.length > 0) {
        if (event.priceDescription.length > 0) {
            [eventAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        [eventAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nTelephone: "
                                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor wh_grey],
                                                                                                   NSFontAttributeName:[UIFont edmondsansBoldOfSize:14.0]}]];
        [eventAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n",event.phoneNumber]
                                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor wh_grey],
                                                                                                   NSFontAttributeName:[UIFont edmondsansRegularOfSize:14.0]}]];
    }
    return eventAttributedString;
}

- (void)setEvent:(WHEventMO *)event
{
    _event = event;

    NSMutableAttributedString * attributedString = [self.class _infoStringWithEvent:event];
    [_descriptionTextView setAttributedText:attributedString];
    
     /*
     if (event.priceDescription.length > 0) {
         [_descriptionTextViewBottomConstraint setConstant:37.0];
     } else {
         [_descriptionTextViewBottomConstraint setConstant:10.0];
     }
      
      */
}
/*
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"%s", __func__);

    return YES;
}*/


@end
