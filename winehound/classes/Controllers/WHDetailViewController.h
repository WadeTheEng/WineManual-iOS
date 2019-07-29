//
//  WHDetailViewController.h
//  WineHound
//
//  Created by Mark Turner on 09/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHWinerySectionHeaderView;
@class CLLocation;

@protocol WHDetailViewControllerProtocol <NSObject>
@required
- (NSString *)titleForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section;
- (UIImage *)imageForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section;
@optional
- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section;

- (NSString *)name;
- (NSString *)phoneNumber;
- (NSString *)email;
- (NSString *)website;
- (CLLocation *)location;

- (NSString *)aboutDescription;
- (NSString *)cellarDoorDescription;

- (NSInteger)numberOfPhotographs;
- (NSURL *)photographURLAtIndex:(NSInteger)index;
@end

////

#import "WHWinerySectionHeaderView.h"
#import "WHContactCell.h"
#import "WHEventsTableCell.h"

@class TableHeaderView;
@interface WHDetailViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDelegate,
WHDetailViewControllerProtocol,
WHEventsTableCellDataSource,
WHWinerySectionHeaderViewDelegate,
WHContactCellDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/*
 TODO: Rather than a property 'expandedSections' with expanded sections indexes.
 Maintain an array of WHSectionInfo objects, which will each maintain whether a section is expanded.
 This is currently duplicate logic implemented in Region & Winery screens.
 
 @property (nonatomic) sectionArray;
 */
@property (nonatomic) NSMutableIndexSet *expandedSections;

@property (nonatomic,weak) TableHeaderView * tableHeaderView;
- (void)headerFavouriteButtonTouchedUpInside:(UIButton *)button;

@end

////

@interface NoCancelTableView : UITableView
@end

////

@interface WHTextViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (void)setTitle:(NSString *)title text:(NSString *)text;
@end
