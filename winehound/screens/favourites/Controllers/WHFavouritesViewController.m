//
//  WHFavouritesViewController.m
//  WineHound
//
//  Created by Mark Turner on 10/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <V8HorizontalPickerView/V8HorizontalPickerView.h>

#import "WHFavouritesViewController.h"
#import "WHFavouriteWinesViewController.h"
#import "WHFavouriteWineriesViewController.h"

#import "WHChildTransitionSegue.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "UIViewController+Appearance.h"

typedef NS_ENUM(NSInteger, WHFavouritesViewState) {
    WHFavouritesViewStateNil,
    WHFavouritesViewStateWineries,
    WHFavouritesViewStateEvents,
    WHFavouritesViewStateWines,
};

NSString * const WHFavouritesViewStateTitle[] = {
    [WHFavouritesViewStateWineries] = @"Wineries",
    [WHFavouritesViewStateEvents]   = @"Events",
    [WHFavouritesViewStateWines]    = @"Wines",
};

@interface WHFavouritesViewController ()
<V8HorizontalPickerViewDataSource,V8HorizontalPickerViewDelegate>
@property (nonatomic) WHFavouritesViewState viewState;
@property (weak, nonatomic) IBOutlet V8HorizontalPickerView *favouriteTypeHorizonalPickerView;
@end

@implementation WHFavouritesViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Favourites"];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self setEdgesForExtendedLayout:UIRectEdgeAll];

    [self setWinehoundTitleView];
    
    if (1 == [self.navigationController.viewControllers count]) {
        [self setBurgerNavBarItem];
    }
    
    [self.favouriteTypeHorizonalPickerView setElementFont:[UIFont edmondsansMediumOfSize:12.0]];
    [self.favouriteTypeHorizonalPickerView setTextColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    [self.favouriteTypeHorizonalPickerView setSelectedTextColor:[UIColor whiteColor]];
    [self.favouriteTypeHorizonalPickerView setBackgroundColor:[UIColor wh_burgundy]];
    
    [self.favouriteTypeHorizonalPickerView setDataSource:self];
    [self.favouriteTypeHorizonalPickerView setDelegate:self];

    [self setViewState:WHFavouritesViewStateWines];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.favouriteTypeHorizonalPickerView setSelectionPoint:CGPointMake(CGRectGetWidth(self.favouriteTypeHorizonalPickerView.bounds)*.5, 0)];
    
    if (self.favouriteTypeHorizonalPickerView.currentSelectedIndex < 0) {
        [self.favouriteTypeHorizonalPickerView scrollToElement:0 animated:NO];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view bringSubviewToFront:self.favouriteTypeHorizonalPickerView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [UIView setAnimationsEnabled:NO];
    //Sets here due to V8HorizontalPickerView bug.
    UIImageView * selectionIndicatorIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"events_month_indicator"]];
    [self.favouriteTypeHorizonalPickerView setSelectionPoint:CGPointMake(CGRectGetWidth(self.favouriteTypeHorizonalPickerView.bounds)*.5, 0)];
    [self.favouriteTypeHorizonalPickerView setSelectionIndicatorView:selectionIndicatorIV];
    [UIView setAnimationsEnabled:YES];
    
    for (WHListViewController * vc in self.childViewControllers) {
        CGFloat originY = CGRectGetMaxY(self.favouriteTypeHorizonalPickerView.frame);
        [vc.view setFrame:(CGRect) {
            .origin.y    = originY,
            .size.width  = CGRectGetWidth(self.view.frame),
            .size.height = CGRectGetHeight(self.view.bounds) - originY
        }];
        [vc.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.bottomLayoutGuide.length, 0)];
        [vc.tableView setScrollIndicatorInsets:vc.tableView.contentInset];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark
#pragma mark

- (void)setViewState:(WHFavouritesViewState)viewState
{
    _viewState = viewState;
    
    switch (_viewState) {
        case WHFavouritesViewStateWines:
            [self performSegueWithIdentifier:@"DisplayWines" sender:nil];
            break;
        case WHFavouritesViewStateEvents:
            [self performSegueWithIdentifier:@"DisplayEvents" sender:nil];
            break;
        default:
        case WHFavouritesViewStateWineries:
            [self performSegueWithIdentifier:@"DisplayWineries" sender:nil];
            break;
    }
}

#pragma mark
#pragma mark V8HorizontalPickerViewDataSource

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
    return WHFavouritesViewStateWines;
}

#pragma mark V8HorizontalPickerViewDelegate

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index
{
    NSLog(@"%s", __func__);
    WHFavouritesViewState newState = index+1;
    [self setViewState:newState];
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index
{
    return WHFavouritesViewStateTitle[index+1];
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
    if (index != 0) {
        NSString * title = WHFavouritesViewStateTitle[index+1];
        CGRect requiredWidth = [title
                                boundingRectWithSize:picker.frame.size
                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                attributes:@{NSFontAttributeName:picker.elementFont}
                                context:nil];
        return ceilf(requiredWidth.size.width) + 35.0;
    }
    return 80.0;
}

@end