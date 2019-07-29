//
//  WHDetailViewController.m
//  WineHound
//
//  Created by Mark Turner on 09/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHDetailViewController.h"

@implementation NoCancelTableView
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}
@end

////

#import <MapKit/MapKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreLocation/CLLocation.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "WHAboutCell.h"
#import "WHCellarDoorCell.h"
#import "WHEventsTableCell.h"
#import "WHContactCell.h"
#import "WHWinerySectionHeaderView.h"
#import "PCGalleryViewController.h"
#import "WHPhotographMO+Mapping.h"
#import "PCPhoto.h"
#import "WHMapViewController.h"
#import "WHWebViewController.h"

#import "TableHeaderView.h"
#import "UIColor+WineHoundColors.h"
#import "NSString+ReformatTel.h"

@interface WHDetailViewController ()
<
WHWinerySectionHeaderViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
WHContactCellDelegate,
WHEventsTableCellDataSource
>
{
    __weak NSLayoutConstraint * _beigeBackgroundHeightConstraint;
}
@end

@implementation WHDetailViewController

#pragma mark

- (void)dealloc
{
    [self.tableView setDelegate:nil];
    [self.tableView setDataSource:nil];
    [self.tableHeaderView.galleryCollectionView setDataSource:nil];
    [self.tableHeaderView.galleryCollectionView setDelegate:nil];
}

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.tableView registerNib:[WHAboutCell nib]       forCellReuseIdentifier:[WHAboutCell reuseIdentifier]];
    [self.tableView registerNib:[WHCellarDoorCell nib]  forCellReuseIdentifier:[WHCellarDoorCell reuseIdentifier]];
    [self.tableView registerNib:[WHEventsTableCell nib] forCellReuseIdentifier:[WHEventsTableCell reuseIdentifier]];
    [self.tableView registerNib:[WHContactCell nib]     forCellReuseIdentifier:[WHContactCell reuseIdentifier]];
    [self.tableView registerClass:[WHWinerySectionHeaderView class] forHeaderFooterViewReuseIdentifier:[WHWinerySectionHeaderView reuseIdentifier]];

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setDelaysContentTouches:NO];
    [self.tableView setSeparatorColor:[UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setContentInset:(UIEdgeInsets){.top = 64.0,.bottom = 49.0}];//Query top/bottom layout guides rather than magic numbers?
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];

    TableHeaderView * tableHeaderView = [TableHeaderView new];
    [tableHeaderView.galleryCollectionView setDataSource:self];
    [tableHeaderView.galleryCollectionView setDelegate:self];
    [tableHeaderView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 150.0)];
    [tableHeaderView.favouriteButton addTarget:self action:@selector(headerFavouriteButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView setTableHeaderView:tableHeaderView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self setTableHeaderView:tableHeaderView];
    
    UIView * beigeBackground = [UIView new];
    [beigeBackground setBackgroundColor:[UIColor wh_beige]];
    [self.view addSubview:beigeBackground];
    [self.view sendSubviewToBack:beigeBackground];

    [beigeBackground setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[beigeBackground]|"
                                                                      options:0
                                                                      metrics:0
                                                                        views:NSDictionaryOfVariableBindings(beigeBackground)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:beigeBackground
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    NSLayoutConstraint * beigeBackgroundHeightConstraint = nil;
    beigeBackgroundHeightConstraint = [NSLayoutConstraint constraintWithItem:beigeBackground
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:0.0];
    [self.view addConstraint:beigeBackgroundHeightConstraint];
    _beigeBackgroundHeightConstraint = beigeBackgroundHeightConstraint;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (UIViewController * vc in self.tabBarController.childViewControllers) {
        if ([vc isKindOfClass:[PCGalleryViewController class]]) {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    for (UIViewController * vc in self.tabBarController.childViewControllers) {
        if ([vc isKindOfClass:[PCGalleryViewController class]]) {
            return [vc supportedInterfaceOrientations];
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableHeaderView.galleryCollectionView performBatchUpdates:nil completion:nil];
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

- (void)headerFavouriteButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
}

#pragma mark WHDetailViewControllerProtocol 

- (NSString *)titleForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    return nil;
}

- (UIImage *)imageForHeader:(WHWinerySectionHeaderView *)header inSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfPhotographs
{
    return 0;
}

#pragma mark WHEventsTableCellDataSource

- (NSInteger)numberOfEventsInEventsCell:(WHEventsTableCell *)eventsCell
{
    return 0;
}

- (WHEventMO *)eventsCell:(WHEventsTableCell *)eventsCell eventObjectForIndex:(NSInteger)index
{
    return nil;
}

#pragma mark
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    WHWinerySectionHeaderView * winerySectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[WHWinerySectionHeaderView reuseIdentifier]];
    [winerySectionHeaderView setDelegate:self];
    [winerySectionHeaderView.sectionTitleLabel setText:[self titleForHeader:winerySectionHeaderView inSection:section]];
    [winerySectionHeaderView setSection:section];
    [winerySectionHeaderView.sectionImageView setImage:[self imageForHeader:winerySectionHeaderView inSection:section]];
    
    BOOL sectionExpanded = NO;
    if ([self tableView:tableView canCollapseSection:section] == YES) {
        if ([self.expandedSections containsIndex:section]) {
            sectionExpanded = YES;
        }
    }
    [winerySectionHeaderView setExpanded:sectionExpanded animationDuration:0.0];
    
    return winerySectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;//Appears to crash in iOS7
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footerView = [UIView new];
    [footerView setBackgroundColor:[UIColor colorWithRed:149.0/255.0 green:149.0/255.0 blue:149.0/255.0 alpha:1.0]];
    [footerView setFrame:CGRectMake(.0, .0, 100.0, 0.5)];
    return footerView;
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section
{
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark WHWinerySectionHeaderViewDelegate

- (void)didSelectTableViewHeaderSection:(WHWinerySectionHeaderView *)headerView
{
    NSLog(@"%s", __func__);
    
    if ([self.searchDisplayController isActive] == YES) {
        return;
    }
    
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
        [headerView setExpanded:!currentlyExpanded animationDuration:0.2];
        
        if (currentlyExpanded == NO) {
            [self.expandedSections addIndex:selectedSection];

            NSInteger numNewRows = [self tableView:self.tableView numberOfRowsInSection:selectedSection];
            if (numNewRows > 0) {
                NSMutableArray * insertRows = @[].mutableCopy;
                while (numNewRows > 0) {
                    [insertRows addObject:[NSIndexPath indexPathForRow:numNewRows-1 inSection:selectedSection]];
                    numNewRows --;
                }

                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationTop];
                [self.tableView endUpdates];
            }
        }
    };
    
    if (deleteRows.count > 0) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:expandSectionBlock];
        
        [self.tableHeaderView setOffset:0.0];
        [self.expandedSections removeAllIndexes];

        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationTop];
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


#pragma mark - Table Header Gallery Collection View
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfPhotographs];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WHGalleryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[WHGalleryCell reuseIdentifier]
                                                                           forIndexPath:indexPath];
    NSURL * photographURL = [self photographURLAtIndex:indexPath.row];
    [cell downloadImage:photographURL];
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __func__);

    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];

    CGRect collectionCellRect = [self.tableView convertRect:collectionView.frame toView:self.tabBarController.view];
    
    PCGalleryViewController * galleryVC = [PCGalleryViewController new];
    [galleryVC setDataSource:(id)self];
    [galleryVC setDelegate:(id)self];
    [galleryVC setCurrentPageIndex:indexPath.row];
    [galleryVC.view setFrame:collectionCellRect];
    [galleryVC.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    
    [self.tabBarController addChildViewController:galleryVC];
    [self.tabBarController.view addSubview:galleryVC.view];
    [galleryVC didMoveToParentViewController:self.tabBarController];
    [galleryVC.view layoutIfNeeded];
    [collectionView setHidden:YES];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [galleryVC.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
                         [galleryVC.view setFrame:CGRectMake(.0, .0, CGRectGetWidth(self.tabBarController.view.bounds), CGRectGetHeight(self.tabBarController.view.bounds))];
                     } completion:^(BOOL finished) {
                         [galleryVC setFetchFullSize:YES];
                     }];
}

#pragma mark PCGalleryViewControllerDataSource

- (NSUInteger)numberOfPhotosInGallery:(PCGalleryViewController *)gallery
{
    return 0;
}

#pragma mark PCGalleryViewControllerDelegate

- (void)galleryDidDimiss:(PCGalleryViewController *)gallery
{
    NSUInteger galleryIndex = gallery.currentPageIndex;
    
    UICollectionView * galleryCollectionView = self.tableHeaderView.galleryCollectionView;
    [galleryCollectionView setContentOffset:CGPointMake(galleryIndex * CGRectGetWidth(galleryCollectionView.bounds), 0.0)];
    CGRect collectionCellRect = [self.tableView convertRect:galleryCollectionView.frame toView:self.tabBarController.view];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [gallery.view setFrame:collectionCellRect];
                         [gallery.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
                     } completion:^(BOOL finished) {
                         [galleryCollectionView setHidden:NO];
                         [gallery.view removeFromSuperview];
                         
                         [gallery willMoveToParentViewController:nil];
                         [gallery removeFromParentViewController];

                         [self.class attemptRotationToDeviceOrientation];
                     }];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModePanningNavigationBar|MMOpenDrawerGestureModeBezelPanningCenterView];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        [_beigeBackgroundHeightConstraint setConstant:scrollView.contentOffset.y < 0.0 ? fabs(scrollView.contentOffset.y) : 0.0];

        if ([self.tableView.tableHeaderView isKindOfClass:[TableHeaderView class]]) {
            TableHeaderView * tableHeaderView = (TableHeaderView *)self.tableView.tableHeaderView;
            [tableHeaderView setOffset:self.tableView.contentOffset.y+self.tableView.contentInset.top];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.tableView.tableHeaderView isKindOfClass:[TableHeaderView class]]) {
        TableHeaderView * tableHeaderView = (TableHeaderView *)self.tableView.tableHeaderView;
        if ([scrollView isEqual:tableHeaderView.galleryCollectionView]) {
            NSInteger pageNumber = (NSInteger)ceilf(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
            if (pageNumber < self.numberOfPhotographs) {
                [tableHeaderView setPageNumber:pageNumber+1];
            }
        }
    }
}

#pragma mark -
#pragma mark WHContactCellDelegate

- (void)contactCell:(WHContactCell *)contactCell didTapDrivingDirectionsButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    NSString * destination = [NSString stringWithFormat:@"%f,%f",self.location.coordinate.latitude,self.location.coordinate.longitude];

    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%@&directionsmode=driving",destination]];
    UIApplication * application = [UIApplication sharedApplication];
    
    if ([application canOpenURL:url]) {
        [application openURL:url];
    } else if ([MKMapItem respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLLocationCoordinate2D destination = self.location.coordinate;
        
        MKMapItem * destinationMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil]];
        [destinationMapItem setName:self.name];
        
        [MKMapItem openMapsWithItems:@[[MKMapItem mapItemForCurrentLocation],destinationMapItem]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsMapTypeKey       :@(MKMapTypeStandard),
                                       MKLaunchOptionsShowsTrafficKey  :@YES}];
    } else {
        NSLog(@"Cannot provide directions");
    }
}

- (void)contactCell:(WHContactCell *)contactCell didTapPhoneButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    UIApplication * application = [UIApplication sharedApplication];
    NSURL * telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",self.phoneNumber.escaped]];
    if ([application canOpenURL:telURL] == YES) {
        [application openURL:telURL];
    }
}

- (void)contactCell:(WHContactCell *)contactCell didTapEmailButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if (self.email != nil) {
        MFMailComposeViewController *emailViewController = [[MFMailComposeViewController alloc] init];
        if (emailViewController != nil) {
            [emailViewController setMailComposeDelegate:(id)self];
            [emailViewController setToRecipients:@[self.email]];
            [self presentViewController:emailViewController animated:YES completion:nil];
        }
    }
}

- (void)contactCell:(WHContactCell *)contactCell didTapWebsiteButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if (self.website != nil) {
        WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrlString:self.website];
        UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)contactCell:(WHContactCell *)contactCell didTapMapView:(GMSMapView *)mapView
{
    UIStoryboard * mapStoryboard = [UIStoryboard storyboardWithName:@"Map" bundle:[NSBundle mainBundle]];
    WHMapViewController * mapVC = [mapStoryboard instantiateInitialViewController];
    [mapVC setMarkerLocation:self.location.coordinate];
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark WHAboutCellDelegate

- (void)aboutCell:(WHAboutCell *)cell didTapReadMoreButton:(UIButton *)button
{
    WHTextViewController * textViewController = [WHTextViewController new];
    [textViewController setTitle:@"About" text:self.aboutDescription];
    [self.navigationController pushViewController:textViewController animated:YES];
}

- (void)aboutCell:(WHAboutCell *)cell didTapURL:(NSURL *)url
{
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:url];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark WHCellarDoorCellDelegate

- (void)cellarDoorCell:(WHCellarDoorCell *)cell didSelectReadMoreButton:(UIButton *)button
{
    WHTextViewController * textViewController = [WHTextViewController new];
    [textViewController setTitle:@"Cellar Door" text:self.cellarDoorDescription];
    [self.navigationController pushViewController:textViewController animated:YES];
}

- (void)cellarDoorCell:(WHCellarDoorCell *)cell didTapURL:(NSURL *)url
{
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:url];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#import "UIFont+Edmondsans.h"
#import "NSAttributedString+HTML.h"

@interface WHTextViewController () <UITextViewDelegate>
@end

@implementation WHTextViewController {
    NSString * _titleString;
    NSString * _bodyString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
    [textView setDelegate:self];
    [textView setTextContainerInset:UIEdgeInsetsMake(10.0, 10.0, 20.0, 10.0)];
    [textView setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [textView setTextColor:[UIColor wh_grey]];
    [textView setDataDetectorTypes:UIDataDetectorTypeAll];
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textView setSelectable:YES];
    [textView setEditable:NO];
    
    [self.view addSubview:textView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[textView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(textView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(textView)]];

    _textView = textView;
    
    ///
    
    [self setTitle:_titleString];
    [self.textView setAttributedText:[NSAttributedString wh_attributedStringWithHTMLString:_bodyString]];
}

- (void)setTitle:(NSString *)title text:(NSString *)text
{
    _titleString = title;
    _bodyString  = text;
    
    if ([self isViewLoaded]) {
        [self setTitle:_titleString];
        [self.textView setAttributedText:[NSAttributedString wh_attributedStringWithHTMLString:_bodyString]];
    }
}

#pragma mark
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSLog(@"%s", __func__);
    
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:URL];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
    
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    NSLog(@"%s", __func__);
    return YES;
}

@end
