//
//  WHCalendarHeaderView.m
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHCalendarHeaderView.h"
#import "UIFont+Edmondsans.h"

@implementation WHCalendarHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.daysLabels enumerateObjectsUsingBlock:^(UILabel * label, NSUInteger idx, BOOL *stop) {
        [label setFont:[UIFont edmondsansRegularOfSize:12.0]];
        [label setTextColor:[UIColor colorWithRed:57.0/255.0 green:57.0/255.0 blue:57.0/255.0 alpha:1.0]];
    }];
    [self.containerView.layer setCornerRadius:4.0];
    [self.containerView.layer setMasksToBounds:YES];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [self.class reuseIdentifier];
}

@end
