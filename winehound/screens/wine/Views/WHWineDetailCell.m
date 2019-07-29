//
//  WHWineDetailCell.m
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineDetailCell.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation WHWineDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.textLabel setNumberOfLines:0];
        [self.textLabel setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

+ (CGFloat)cellHeightForAttributedString:(NSAttributedString *)attrString
{
    CGRect sizeToFit = [attrString boundingRectWithSize:CGSizeMake(300.0, CGFLOAT_MAX)
                                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                context:nil];
    return sizeToFit.size.height > 24.0 ? ceilf(sizeToFit.size.height) : 24.0;
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.textLabel setFrame:CGRectMake(10.0, .0, CGRectGetWidth(self.frame) - 20.0, CGRectGetHeight(self.frame))];
}

@end
