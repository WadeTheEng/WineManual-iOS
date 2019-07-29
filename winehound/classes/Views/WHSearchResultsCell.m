//
//  WHSearchResultsCell.m
//  WineHound
//
//  Created by Mark Turner on 13/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHSearchResultsCell.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation WHSearchResultsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.textLabel setFont:[UIFont edmondsansRegularOfSize:17.0]];
        [self.textLabel setTextColor:[UIColor wh_grey]];
        [self setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"winery_standard_accesory"]]];
        [self setSelectedBackgroundView:[UIView new]];
        [self.selectedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
        [self setBackgroundView:[UIView new]];

        UIView * seperatorView = [UIView new];
        [seperatorView setBackgroundColor:[UIColor colorWithWhite:208.0/255.0 alpha:1.0]];
        [seperatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.backgroundView addSubview:seperatorView];
        [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[seperatorView]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(seperatorView)]];
        [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[seperatorView(==2)]|"
                                                                                    options:NSLayoutFormatAlignAllBottom
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(seperatorView)]];
    }
    return self;
}

+ (CGFloat)cellHeight
{
    return 40.0;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [self.class reuseIdentifier];
}

@end;
