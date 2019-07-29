//
//  WHSettingsViewController.m
//  WineHound
//
//  Created by Mark Turner on 27/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHSettingsViewController.h"
#import "WHFavouriteManager.h"
#import "WHWineriesScheduledLocationManager.h"

#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

@interface HighlightControl : UIControl @end

@implementation HighlightControl

- (void)setHighlighted:(BOOL)highlighted
{
    [self setBackgroundColor:highlighted?[[UIColor wh_grey] colorWithAlphaComponent:0.2]:[UIColor whiteColor]];
}

@end


@interface WHSettingsViewController ()

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *allLabels;

@property (weak, nonatomic) IBOutlet UILabel  *emailLabel;

@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationsSwitch;

@property (weak, nonatomic) IBOutlet UIControl *emailControlView;

@end

@implementation WHSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Settings"];
    
    [self.allLabels enumerateObjectsUsingBlock:^(UILabel * label, NSUInteger idx, BOOL *stop) {
        [label setFont:[UIFont edmondsansRegularOfSize:14.0]];
        [label setTextColor:[UIColor wh_grey]];
    }];
    
    [self.pushNotificationsSwitch setTintColor:[UIColor wh_burgundy]];
    [self.pushNotificationsSwitch setOnTintColor:[UIColor wh_burgundy]];
    [self.pushNotificationsSwitch addTarget:self action:@selector(_pushSwitchValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.emailLabel setText:[WHFavouriteManager email]];

    [self.emailControlView addTarget:self
                              action:@selector(_emailControlTouchedUpInside:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    BOOL pushEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kWHUserDefaultsPushEnabled];
    [self.pushNotificationsSwitch setOn:pushEnabled];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark

- (void)_applicationDidEnterForeground:(NSNotification *)notification
{
    BOOL pushEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kWHUserDefaultsPushEnabled];
    [self.pushNotificationsSwitch setOn:pushEnabled animated:YES];
}

- (void)_pushSwitchValueDidChange:(UISwitch *)sw
{
    [[NSUserDefaults standardUserDefaults] setBool:sw.isOn forKey:kWHUserDefaultsPushEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_emailControlTouchedUpInside:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"ChangeEmail" sender:nil];
}

@end
