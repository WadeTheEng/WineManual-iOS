//
//  WHSideMenuViewController.m
//  WineHound
//
//  Created by Mark Turner on 26/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHSideMenuViewController.h"
#import "WHEventsCalendarViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"

@interface WHSideMenuViewController ()
{
    __weak IBOutlet NSLayoutConstraint *_wineHoundLogoBottomConstraint;
    __weak IBOutlet NSLayoutConstraint *_wineHoundLogoHeightConstraint;
}
@end

@implementation WHSideMenuViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor wh_grey]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setScrollsToTop:NO];
    [self.tableView setScrollEnabled:NO];
    
    UIView * whLogoView = (UIView*)_wineHoundLogoBottomConstraint.secondItem;
    [_wineHoundLogoBottomConstraint setConstant:-CGRectGetHeight(whLogoView.frame)];
    
    [self.tableView setContentInset:(UIEdgeInsets){.top = [[UIApplication sharedApplication] statusBarFrame].size.height}];
}

- (void)updateViewConstraints
{
    if (CGRectGetHeight(self.view.frame) <= 500.0) {
        [_wineHoundLogoHeightConstraint setConstant:180.0];
    }
    [super updateViewConstraints];
}

#pragma mark 

- (void)setWineHoundLogoOffset:(CGFloat)offset
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        [_wineHoundLogoBottomConstraint setConstant:-(20+((1.0-(offset*offset*offset))*_wineHoundLogoHeightConstraint.constant))];
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [UITableViewCell new];
    [cell setBackgroundColor:[UIColor wh_grey]];
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont edmondsansRegularOfSize:18.0]];

    [cell setSelectedBackgroundView:[UIView new]];
    [cell.selectedBackgroundView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.05]];
    
    if (indexPath.row != [tableView numberOfRowsInSection:indexPath.section]-1) {
        UIView * seperatorView = [UIView new];
        [seperatorView setFrame:CGRectMake(1.0,1.0,1.0,1.0)];
        [seperatorView setBackgroundColor:[UIColor whiteColor]];
        [seperatorView setTranslatesAutoresizingMaskIntoConstraints:NO];

        [cell.contentView addSubview:seperatorView];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[seperatorView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(seperatorView)]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[seperatorView(0.5)]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(seperatorView)]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (CGRectGetHeight(self.view.frame) <= 500.0) {
        return 60.0;
    } else {
        return 75.0;
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [cell.imageView setImage:[UIImage imageNamed:@"menu_wine_icon"]];
            [cell.textLabel setText:@"Wines"];
            break;
        case 1:
            [cell.imageView setImage:[UIImage imageNamed:@"menu_event_icon"]];
            [cell.textLabel setText:@"Trade Events"];
            break;
        case 2:
            [cell.imageView setImage:[UIImage imageNamed:@"menu_about_icon"]];
            [cell.textLabel setText:@"About Winehound"];
            break;
        case 3:
            [cell.imageView setImage:[UIImage imageNamed:@"menu_settings_icon"]];
            [cell.textLabel setText:@"Settings"];
            break;
        default:
            break;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController * vc = nil;
    switch (indexPath.row) {
        case 0: {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Wine" bundle:[NSBundle mainBundle]];
            vc = [storyboard instantiateViewControllerWithIdentifier:@"WHWineListViewController"];
        }
            break;
        case 1: {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"EventsCalendar" bundle:[NSBundle mainBundle]];
            WHEventsCalendarViewController * eventsCalendarVC = [storyboard instantiateViewControllerWithIdentifier:@"WHEventsCalendarViewController"];
            [eventsCalendarVC setDisplayTradeEvents:YES];
            vc = eventsCalendarVC;
        }
            break;
        case 2: {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"About" bundle:[NSBundle mainBundle]];
            vc = [storyboard instantiateInitialViewController];
        }
            break;
        case 3: {
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
            vc = [storyboard instantiateInitialViewController];
        }
            break;
        default:
            break;
    }
    
    //TODO - Cleanup
    
    if ([self.mm_drawerController.centerViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController * centerTabBarController = (id)self.mm_drawerController.centerViewController;
        
        if ([centerTabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
            
            UINavigationController * navController = (UINavigationController *)centerTabBarController.selectedViewController;
            [navController pushViewController:vc animated:YES];
        }
    }
}

@end
