//
//  WHWineriesViewController.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineriesViewController.h"
#import "WHWineriesMapViewController.h"
#import "WHWineriesListViewController.h"
#import "WHChildTransitionSegue.h"

#import "UIViewController+Appearance.h"
#import "UIViewController+MMDrawerController.h"

typedef NS_ENUM(NSInteger, WHWineriesViewState) {
    WHWineriesViewStateNil,
    WHWineriesViewStateMap,
    WHWineriesViewStateList,
};

@interface WHWineriesViewController () <UITabBarControllerDelegate>
@property (nonatomic) WHWineriesViewState viewState;
@property (nonatomic) WHWineriesMapViewController  * wineriesMapViewController;
@property (nonatomic) WHWineriesListViewController * wineriesListViewController;
@end

@implementation WHWineriesViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Wineries"];
    [self setWinehoundTitleView];
    [self setViewState:WHWineriesViewStateList];
    
    if (1 == [self.navigationController.viewControllers count]) {
        [self setBurgerNavBarItem];
    }
    
    /*
    [self.tabBarController setDelegate:self];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"List"]) {
        WHWineriesListViewController * listVC = (WHWineriesListViewController*)segue.destinationViewController;
        [listVC setRegionId:self.regionId];
    }
    if ([segue.identifier isEqualToString:@"Map"]) {
        WHWineriesMapViewController * mapVC = (WHWineriesMapViewController*)segue.destinationViewController;
        [mapVC setRegionId:self.regionId];
        [mapVC setFetchWineryTypes:WHWineryMapTypeAll];
    }
}

- (BOOL)shouldAutorotate
{
    /*
    if (self.childViewControllers.count > 0) {
        return [self.childViewControllers.lastObject shouldAutorotate];
    }
     */
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    /*
    if (self.childViewControllers.count > 0) {
        return [self.childViewControllers.lastObject shouldAutorotate];
    }
     */
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isEqual:self.navigationController]) {
        if (_viewState != WHWineriesViewStateList) {
            [self setViewState:WHWineriesViewStateList];
        }
    }
}

#pragma mark 

- (void)setRegionId:(NSNumber *)regionId
{
    _regionId = regionId;

    [_wineriesListViewController setRegionId:_regionId];
    [_wineriesMapViewController  setRegionId:_regionId];
}

#pragma mark
#pragma mark

- (void)setViewState:(WHWineriesViewState)viewState
{
    _viewState = viewState;
    
    switch (_viewState) {
        case WHWineriesViewStateList: {
            [self.wineriesListViewController setRegionId:self.regionId];
            
            WHChildTransitionSegue * transitionSegue =
            [[WHChildTransitionSegue alloc] initWithIdentifier:@"List"
                                                        source:self
                                                   destination:self.wineriesListViewController];

            __weak typeof (self) weakSelf = self;
            [transitionSegue setCompletionBlock:^{
                [weakSelf.navigationItem.rightBarButtonItem setEnabled:YES];
            }];
            [transitionSegue perform];

            [weakSelf.navigationItem.rightBarButtonItem setTitle:@"Map"];
        }
            break;
        case WHWineriesViewStateMap:
        default: {
            [self.wineriesMapViewController setRegionId:self.regionId];
            [self.wineriesMapViewController setFetchWineryTypes:WHWineryMapTypeAll];
            
            WHChildTransitionSegue * transitionSegue =
            [[WHChildTransitionSegue alloc] initWithIdentifier:@"Map"
                                                        source:self
                                                   destination:self.wineriesMapViewController];
            __weak typeof (self) weakSelf = self;
            [transitionSegue setCompletionBlock:^{
                [weakSelf.navigationItem.rightBarButtonItem setEnabled:YES];
            }];
            [transitionSegue perform];

            [weakSelf.navigationItem.rightBarButtonItem setTitle:@"List"];
        }
            break;
    }
}

#pragma mark
#pragma mark Lazy Getters

- (WHWineriesMapViewController *)wineriesMapViewController
{
    if (_wineriesMapViewController == nil) {
        id vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WHWineriesMapViewController"];
        _wineriesMapViewController = vc;
    }
    return _wineriesMapViewController;
}

- (WHWineriesListViewController *)wineriesListViewController
{
    if (_wineriesListViewController == nil) {
        id vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WHWineriesListViewController"];
        _wineriesListViewController = vc;
    }
    return _wineriesListViewController;
}

#pragma mark 
#pragma mark Actions

- (IBAction)navBarToggleButtonAction:(UIBarButtonItem *)sender
{
    [sender setEnabled:NO];
    
    if (self.viewState == WHWineriesViewStateMap) {
        [self setViewState:WHWineriesViewStateList];
    } else {
        [self setViewState:WHWineriesViewStateMap];
    }
}

@end
