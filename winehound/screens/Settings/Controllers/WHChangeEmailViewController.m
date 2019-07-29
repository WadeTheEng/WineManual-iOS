//
//  WHSettingsViewController.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <iAd/iAd.h>

#import "WHChangeEmailViewController.h"
#import "UIViewController+Appearance.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "UIButton+WineHoundButtons.h"

#import "WHFavouriteManager.h"

@interface WHChangeEmailViewController () <UITextFieldDelegate,ADBannerViewDelegate>
{
    __weak IBOutlet UILabel     *_infoLabel;
    __weak IBOutlet UIButton    *_changeEmailButton;
    __weak IBOutlet UITextField *_textField;
    
    __weak IBOutlet UIView      *_topStroke;
    __weak IBOutlet UIView      *_bottomStroke;
    
    __weak IBOutlet ADBannerView *_adBannerView;
}
@end

@implementation WHChangeEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Change Email"];
    
    [_adBannerView setHidden:YES];
    [_adBannerView setDelegate:self];
    
    [_infoLabel setFont:[UIFont edmondsansRegularOfSize:17.0]];
    [_infoLabel setTextColor:[UIColor wh_grey]];
    
    [_textField setTextColor:[UIColor wh_grey]];
    [_textField setFont:[UIFont edmondsansMediumOfSize:17.0]];
    [_textField setPlaceholder:@"Email"];
    [_textField setDelegate:self];
    
    [_changeEmailButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
    [_changeEmailButton setBackgroundColor:[UIColor whiteColor]];
    [_changeEmailButton addTarget:self action:@selector(_changeEmailButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_changeEmailButton setTitleEdgeInsets:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_textField setText:[WHFavouriteManager email]];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

- (void)_changeEmailButtonTouchedUpInside:(UIButton *)button
{
    [WHFavouriteManager setEmail:_textField.text];
    
    [[[UIAlertView alloc] initWithTitle:@"Email Changed"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

#pragma mark
#pragma mark ADBannerViewDelegate

- (void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    NSLog(@"%s", __func__);
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"%s", __func__);
    [_adBannerView setHidden:NO];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"%s - %@", __func__,error);
    [_adBannerView setHidden:YES];
}

@end
