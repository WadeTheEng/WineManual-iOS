//
//  WHTastingNoteCell.m
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHTastingNoteCell.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation WHTastingNoteCell

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];

    [_tastingTitleLabel       setFont:[UIFont edmondsansMediumOfSize:14.0]];
    [_tastingDescriptionLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    
    [_tastingTitleLabel       setTextColor:[UIColor wh_grey]];
    [_tastingDescriptionLabel setTextColor:[UIColor wh_grey]];
}

- (void)setTitle:(NSString *)title detail:(NSString *)detail
{
    [_tastingTitleLabel setText:title];
    [_tastingDescriptionLabel setText:detail];
}

#pragma mark

+ (CGFloat)cellHeightForTitle:(NSString *)title detail:(NSString *)detail
{
    const CGFloat kSpacing = 7.0;
    const CGFloat kPadding = 10.0;
    NSDictionary * attributes = @{NSFontAttributeName: [UIFont edmondsansRegularOfSize:15.0]};
    CGRect requiredTitleBoundingBox  = [title  boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                         attributes:attributes
                                                            context:nil];
    CGRect requiredDetailBoundingBox = [detail boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                         attributes:attributes
                                                            context:nil];
    return (kSpacing+kPadding) + ceilf(requiredTitleBoundingBox.size.height) + ceilf(requiredDetailBoundingBox.size.height);
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}


@end
