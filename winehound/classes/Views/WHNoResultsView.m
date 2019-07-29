//
//  WHNoResultsView.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHNoResultsView.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation WHNoResultsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.noResultsLabel setTextColor:[UIColor wh_grey]];
    [self.noResultsLabel setFont:[UIFont edmondsansMediumOfSize:15.0]];
}

+ (id)new
{
    NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"temp_no_results_view" owner:nil options:nil];
    return [views firstObject];
}

@end
