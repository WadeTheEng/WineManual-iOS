//
//  WHFilterViewController.m
//  WineHound
//
//  Created by Mark Turner on 04/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHFilterViewController.h"
#import "WHWinerySectionHeaderView.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@interface WHFilterViewCell : UITableViewCell @end

@implementation WHFilterViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.textLabel setFont:[UIFont edmondsansRegularOfSize:16.0]];
        [self.textLabel setTextColor:[UIColor wh_grey]];
        
        UIImageView * iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filter_row_deselected"] highlightedImage:[UIImage imageNamed:@"filter_row_selected"]];
        [self setAccessoryView:iv];
        
        /*
        [self setSelectedBackgroundView:[UIView new]];
        [self.selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
        
        UIView * seperatorView = [UIView new];
        [seperatorView setFrame:CGRectMake(1.0,1.0,1.0,1.0)];
        [seperatorView setBackgroundColor:[UIColor redColor]];
        [self.contentView addSubview:seperatorView];
        
        [seperatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [seperatorView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:0
                                                                 multiplier:1.0
                                                                   constant:0.5]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:10.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0
                                                                      constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0.0]];
         */
    }
    return self;
}

@end

//

#import "UIButton+WineHoundButtons.h"

@interface WHFilterViewController () <UITableViewDataSource,UITableViewDelegate,WHWinerySectionHeaderViewDelegate>
{
    __weak UIButton    * _hideButton;
    
    NSMutableSet * _selectedRows;
    
    BOOL _isAnimatingTableSections;
}
@property (nonatomic) NSMutableIndexSet * expandedSections;
@property (nonatomic,weak) UITableView * tableView;
@end

@implementation WHFilterViewController

#pragma mark
#pragma mark View lifecycle

- (void)loadView
{
    UIView * view = [UIView new];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    UITableView * tableView = [UITableView new];
    [view addSubview:tableView];

    UIButton * hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [view addSubview:hideButton];
    
    [self setView:view];

    _tableView = tableView;
    _hideButton = hideButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView registerClass:[WHFilterViewCell class] forCellReuseIdentifier:@"FilterCell"];
    [_tableView registerClass:[WHWinerySectionHeaderView class] forHeaderFooterViewReuseIdentifier:[WHWinerySectionHeaderView reuseIdentifier]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setDelaysContentTouches:NO];

    [_hideButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:1.0];
    [_hideButton setTitle:@"Apply Filters" forState:UIControlStateNormal];
    [_hideButton setTitleEdgeInsets:UIEdgeInsetsMake(.0, .0, .0, .0)];
    [_hideButton addTarget:self action:@selector(_hideButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_hideButton setFrame:(CGRect){10.0,CGRectGetHeight(self.view.frame) - 44.0,300.0,36.0}];
    [_tableView  setFrame:(CGRect){.0,0.0,CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - 44.0}];
    
    /*
    [_tableView setContentInset:(UIEdgeInsets){ .bottom = 44.0}];
    [_tableView setScrollIndicatorInsets:_tableView.contentInset];
     */
}

#pragma mark

- (NSMutableIndexSet *)expandedSections
{
    if (_expandedSections == nil) {
        _expandedSections = [NSMutableIndexSet new];
    }
    return _expandedSections;
}

#pragma mark
#pragma mark Actions

- (void)_hideButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterViewController:didTapHideButton:)]) {
        [self.delegate filterViewController:self didTapHideButton:button];
    }
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.dataSource respondsToSelector:@selector(filterViewControllerNumberOfFilterSections:)])
        return [self.dataSource filterViewControllerNumberOfFilterSections:self];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [WHWinerySectionHeaderView viewHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString * title = nil;
    if ([self.dataSource respondsToSelector:@selector(filterViewController:titleForFilterSection:)]) {
        title = [self.dataSource filterViewController:self titleForFilterSection:section];
    }
    NSString * detailString = nil;
    if ([self.dataSource respondsToSelector:@selector(filterViewController:detailForFilterSection:)]) {
        detailString = [self.dataSource filterViewController:self detailForFilterSection:section];
    }
    
    WHWinerySectionHeaderView * winerySectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[WHWinerySectionHeaderView reuseIdentifier]];
    [winerySectionHeaderView setTitleLabelLeftInset:15.0];
    [winerySectionHeaderView.sectionTitleLabel setTextColor:[UIColor wh_grey]];
    [winerySectionHeaderView.sectionTitleLabel setText:title];
    [winerySectionHeaderView.sectionDetailLabel setText:detailString];
    [winerySectionHeaderView setSection:section];
    [winerySectionHeaderView.sectionImageView setImage:nil];
    [winerySectionHeaderView setDelegate:self];
    
    BOOL sectionExpanded = [self.expandedSections containsIndex:section];
    [winerySectionHeaderView setExpanded:sectionExpanded animationDuration:0.0];
    
    return winerySectionHeaderView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.expandedSections containsIndex:section]) {
        if ([self.dataSource respondsToSelector:@selector(filterViewController:numerOfItemsForFilterSection:)]) {
            return [self.dataSource filterViewController:self numerOfItemsForFilterSection:section];
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
    NSString * cellTitle = nil;
    if ([self.dataSource respondsToSelector:@selector(filterViewController:filterItemTitleForIndexPath:)]) {
        cellTitle = [self.dataSource filterViewController:self filterItemTitleForIndexPath:indexPath];
    }
    [cell.textLabel setText:cellTitle];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView * iv = (UIImageView *)cell.accessoryView;
    
    if ([self.delegate respondsToSelector:@selector(filterViewController:filterItemSelected:)]) {
        [iv setHighlighted:[self.delegate filterViewController:self filterItemSelected:indexPath]];
    } else {
        [iv setHighlighted:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(filterViewController:didSelectFilterItem:)]) {
        [self.delegate filterViewController:self didSelectFilterItem:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData]; //iOS7 issue where by seperator above dissapears.
    
    /*
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
     */
}


#pragma mark WHWinerySectionHeaderViewDelegate

- (void)didSelectTableViewHeaderSection:(WHWinerySectionHeaderView *)headerView
{
    NSLog(@"%s", __func__);
    
    if ([self.searchDisplayController isActive] == YES || _isAnimatingTableSections) {
        return;
    }
    
    _isAnimatingTableSections = YES;
    
    NSMutableArray * deleteRows = [NSMutableArray array];
    NSMutableIndexSet * reloadSections = [NSMutableIndexSet indexSet];
    
    [self.expandedSections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        [reloadSections addIndex:section];
        NSInteger rows = [self.tableView numberOfRowsInSection:section];
        while (rows > 0) {
            [deleteRows addObject:[NSIndexPath indexPathForRow:rows-1 inSection:section]];
            rows --;
        }
    }];
    
    NSInteger selectedSection = headerView.section;
    BOOL currentlyExpanded = [self.expandedSections containsIndex:selectedSection];
    
    void(^expandSectionBlock)() = ^{
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            _isAnimatingTableSections = NO;
        }];
        
        [headerView setExpanded:!currentlyExpanded animationDuration:0.2];
        
        [self.tableView beginUpdates];
        if (currentlyExpanded == NO) {
            [self.expandedSections addIndex:selectedSection];
            
            NSInteger numNewRows = 0;
            if ([self.dataSource respondsToSelector:@selector(filterViewController:numerOfItemsForFilterSection:)]) {
                numNewRows = [self.dataSource filterViewController:self numerOfItemsForFilterSection:selectedSection];
            } else {
                numNewRows = [self tableView:self.tableView numberOfRowsInSection:selectedSection];
            }

            NSMutableArray * insertRows = @[].mutableCopy;
            while (numNewRows > 0) {
                [insertRows addObject:[NSIndexPath indexPathForRow:numNewRows-1 inSection:selectedSection]];
                numNewRows --;
            }
            [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationTop];
        }
        [self.tableView endUpdates];
        
        [CATransaction commit];
    };
    
    if (deleteRows.count > 0) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:expandSectionBlock];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationTop];
        [self.expandedSections removeAllIndexes];
        [self.tableView endUpdates];
        
        //Animate chevrons
        [reloadSections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            WHWinerySectionHeaderView * expandedHeaderView = (id)[self.tableView headerViewForSection:section];
            [expandedHeaderView setExpanded:NO animationDuration:0.2];
        }];
        
        [CATransaction commit];
    } else {
        expandSectionBlock();
    }
}

@end
