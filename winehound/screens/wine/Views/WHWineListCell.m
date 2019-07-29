//
//  WHWineListCell.m
//  WineHound
//
//  Created by Mark Turner on 18/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHWineListCell.h"
#import "UIFont+Edmondsans.h"

@implementation WHWineListCell

+ (CGFloat)cellHeight
{
    return 117.0;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.titleLabel setFont:[UIFont edmondsansBoldOfSize:14.0]];
    [self.descriptionLabel setFont:[UIFont edmondsansRegularOfSize:11.0]];
    [self.activityIndicatorView setTransform:CGAffineTransformMakeScale(0.75, 0.75)];
}

@end
