//
//  UIViewController+Appearance.m
//  WineHound
//
//  Created by Mark Turner on 17/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "UIViewController+Appearance.h"
#import "UIViewController+MMDrawerController.h"

@implementation UIViewController (Appearance)

- (void)setWinehoundTitleView
{
    UIImage * winehoundTitleImage = [UIImage imageNamed:@"winehound_title_logo"];
    UIImageView * wineHoundTitleImageView = [[UIImageView alloc] initWithImage:winehoundTitleImage];
    [self.navigationItem setTitleView:wineHoundTitleImageView];
}

- (void)setBurgerNavBarItem
{
    UIBarButtonItem * burgerButtonItem = [[UIBarButtonItem alloc]
                                          initWithImage:[UIImage imageNamed:@"burger_icon"]
                                          style:UIBarButtonItemStyleBordered
                                          target:self
                                          action:@selector(burgerButtonAction:)];
    [self.navigationItem setLeftBarButtonItem:burgerButtonItem];
}

- (IBAction)burgerButtonAction:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
