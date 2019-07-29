//
//  WHApperance.m
//  WineHound
//
//  Created by Mark Turner on 17/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHApperance.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

@implementation WHApperance

+ (void)setupAppearance
{
    [[UIToolbar appearance]       setBarTintColor:[[UIColor wh_beige] colorWithAlphaComponent:0.8]];
    [[UITabBar appearance]        setBarTintColor:[[UIColor wh_beige] colorWithAlphaComponent:0.8]];
    [[UINavigationBar appearance] setBarTintColor:[[UIColor wh_beige] colorWithAlphaComponent:0.8]];
        
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont edmondsansRegularOfSize:22.0],
                                                           NSForegroundColorAttributeName: [UIColor wh_grey]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont edmondsansRegularOfSize:18.0],
                                                           NSForegroundColorAttributeName: [UIColor wh_grey]}
                                                forState:UIControlStateNormal];
}

@end
