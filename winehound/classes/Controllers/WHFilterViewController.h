//
//  WHFilterViewController.h
//  WineHound
//
//  Created by Mark Turner on 04/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHFilterViewControllerDelegate;
@protocol WHFilterViewControllerDataSource;

@interface WHFilterViewController : UIViewController
@property (nonatomic,weak) id <WHFilterViewControllerDelegate>   delegate;
@property (nonatomic,weak) id <WHFilterViewControllerDataSource> dataSource;
@end

@protocol  WHFilterViewControllerDelegate <NSObject>
- (BOOL)filterViewController:(WHFilterViewController *)vc filterItemSelected:(NSIndexPath *)indexPath;
- (void)filterViewController:(WHFilterViewController *)vc didSelectFilterItem:(NSIndexPath *)indexPath;
- (void)filterViewController:(WHFilterViewController *)vc didTapHideButton:(UIButton *)hideButton;
@end

@protocol WHFilterViewControllerDataSource <NSObject>
@optional
- (NSInteger)filterViewControllerNumberOfFilterSections:(WHFilterViewController *)vc;
- (NSString *)filterViewController:(WHFilterViewController *)vc titleForFilterSection:(NSInteger)section;
- (NSString *)filterViewController:(WHFilterViewController *)vc detailForFilterSection:(NSInteger)section;
@required
- (NSInteger)filterViewController:(WHFilterViewController *)vc numerOfItemsForFilterSection:(NSInteger)section;
- (NSString *)filterViewController:(WHFilterViewController *)vc filterItemTitleForIndexPath:(NSIndexPath *)indexPath;
@end