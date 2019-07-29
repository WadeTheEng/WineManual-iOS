//
//  WHWineViewController.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <PCDefaults/PCDefaults.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <RestKit/Network/RKPathMatcher.h>

#import "WHWineViewController.h"
#import "WHWebViewController.h"
#import "WHPDFViewController.h"
#import "WHWineCarouselCell.h"
#import "WHWineBuyShareCell.h"
#import "WHWineDescriptionCell.h"
#import "WHTastingNoteCell.h"
#import "WHWineDetailCell.h"
#import "WHWineMO+Additions.h"
#import "WHWineMO+Mapping.h"
#import "WHWineRangeMO.h"

#import "WHAlertView.h"
#import "WHFavouriteMO+Additions.h"
#import "WHFavouriteAlertView.h"
#import "WHFavouriteManager.h"
#import "WHShareManager.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "UIButton+WineHoundButtons.h"
#import "WHLoadingHUD.h"
#import "PCDCollectionMergeManagerFixStart.h"

@interface WHWineViewController ()
<
UITableViewDataSource,UITableViewDelegate,
WHWineCarouselCellDataSource,
WHWineCarouselCellDelegate,
WHWineDescriptionCellDelegate
>
{
    PCDCollectionManager * _collectionManager;
    NSArray              * _wineDetailsArray;
    NSArray              * _tastingNotesArray;
    
    WHShareManager * _shareManager;
}
@property (nonatomic,weak)   WHWineMO * wine;
@property (nonatomic,weak)   WHWineRangeMO * wineRange;
@property (nonatomic,strong) NSAttributedString * wineDetailsAttributedString;
@end

@implementation WHWineViewController

#pragma mark
#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setTitle:@"Wines"];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setAllowsSelection:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setDelaysContentTouches:NO];

    [self.tableView setContentInset:(UIEdgeInsets){
        .top = CGRectGetHeight(self.navigationController.navigationBar.bounds) + [UIApplication sharedApplication].statusBarFrame.size.height,
    }];
    [self.tableView setScrollIndicatorInsets:self.tableView.contentInset];
    
    UINib * tastingNoteCellNib = [UINib nibWithNibName:@"WHTastingNoteCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:tastingNoteCellNib forCellReuseIdentifier:[WHTastingNoteCell reuseIdentifier]];
    [self.tableView registerClass:[WHWineDetailCell class] forCellReuseIdentifier:[WHWineDetailCell reuseIdentifier]];
    
    if (_wineryId != nil) {
        PCDCollectionFilter * wineryFilter = [PCDCollectionFilter new];
        [wineryFilter setPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@",_wineryId]];
        [wineryFilter setParameters:@{@"winery_id": _wineryId}];
        
        NSMutableArray * collectionFilters = @[wineryFilter].mutableCopy;
        if (self.rangeId != nil) {
            PCDCollectionFilter * rangeFilter = [PCDCollectionFilter new];
            [rangeFilter setPredicate:[NSPredicate predicateWithFormat:@"wineRangeId == %@",self.rangeId]];
            [rangeFilter setParameters:@{@"wine_range": self.rangeId}];
            [collectionFilters addObject:rangeFilter];
        }
        [self.collectionManager reloadWithFilters:collectionFilters];
    } else if (self.selectedWineId != nil) {
        PCDCollectionFilter * wineFilter = [PCDCollectionFilter new];
        [wineFilter setPredicate:[NSPredicate predicateWithFormat:@"wineId == %@",self.selectedWineId]];
        [self.collectionManager setBaseUrlPath:RKPathFromPatternWithObject(@"/api/wines/:wineId", @{@"wineId":self.selectedWineId})];
        [self.collectionManager reloadWithFilter:wineFilter];
    }
    
    if (self.selectedWineId != nil) {
        [[Mixpanel sharedInstance] track:@"Show Wine" properties:@{@"wine_id": self.selectedWineId}];
    }

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.wine == nil) {
        //Display loading wheel
    }
    
    if (self.selectedWineId != nil) {
        NSInteger selectedWineIndex = 0;
        for (WHWineMO * wineObject in self.collectionManager.objects) {
            if ([wineObject.wineId isEqual:self.selectedWineId]) {
                /*
                [self setWine:wineObject];
                */
                NSInteger index = [self.collectionManager.objects indexOfObject:wineObject];
                selectedWineIndex = index;
                break;
            }
        }
        WHWineCarouselCell * carouselCell = (WHWineCarouselCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [carouselCell scrollToWineAtIndex:selectedWineIndex animated:NO];
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

- (void)dealloc
{
    WHWineCarouselCell * carouselCell = (WHWineCarouselCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [carouselCell setDelegate:nil];
}

#pragma mark

- (WHWineRangeMO *)wineRange
{
    if (_wineRange == nil) {
        WHWineRangeMO * wineRange = [WHWineRangeMO MR_findFirstByAttribute:@"rangeId"
                                                                 withValue:self.rangeId
                                                                 inContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
        _wineRange = wineRange;
    }
    return _wineRange;
}

//- (void)setWineryId:(NSNumber *)wineryId
//{
//    _wineryId = wineryId;
//    
//    if (_wineryId != nil) {
//        PCDCollectionFilter * wineFilter = [PCDCollectionFilter new];
//        [wineFilter setPredicate:[NSPredicate predicateWithFormat:@"wineryId == %@",_wineryId]];
//        [wineFilter setParameters:@{@"wineryId": _wineryId}];
//        [self.collectionManager reloadWithFilter:wineFilter];
//    }
///*
//    [self.collectionManager setFilterPredicate:[NSPredicate predicateWithFormat:@"wineId == %@",self.wineId]];
// */
//}

- (void)setWine:(WHWineMO *)wine
{
    _wine = wine;
    _wineDetailsAttributedString = nil;
    _wineDetailsArray  = nil;
    _tastingNotesArray = nil;
}

- (PCDCollectionManager *)collectionManager
{
    if (_collectionManager == nil) {
        __weak typeof(self) blockSelf = self;

        PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHWineMO class]];
        [collectionManager setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"winerySortPosition" ascending:YES]]];
        [collectionManager setUpdateBlock:^(NSArray *objects) {
            NSInteger selectedWineIndex = 0;
            if (blockSelf.selectedWineId != nil) {
                for (WHWineMO * wineObject in objects) {
                    if ([wineObject.wineId isEqual:blockSelf.selectedWineId]) {
                        [blockSelf setWine:wineObject];

                        NSInteger index = [objects indexOfObject:wineObject];
                        selectedWineIndex = index;
                    }
                }
            } else {
                [blockSelf setWine:objects.firstObject];
            }
            WHWineCarouselCell * carouselCell = (WHWineCarouselCell*)[blockSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [carouselCell reload];
            [carouselCell scrollToWineAtIndex:selectedWineIndex animated:NO];
        }];
        [collectionManager setNetworkUpdateBlock:^(BOOL success,BOOL noResults,NSError * error) {
            if (success == NO || noResults == YES)
                NSLog(@"Error - Fetch wine failure: %@",error);
        }];
        
        _collectionManager = (PCDCollectionManager *)collectionManager;
    }
    return _collectionManager;
}

- (NSArray *)wineDetailsArray
{
    if (_wineDetailsArray == nil) {
        NSMutableArray * wineDetailsArray = @[].mutableCopy;
        (self.wine.vintage.length>0)       ?[wineDetailsArray addObject:@[@"Vintage",self.wine.vintage]]:nil;
        (self.wine.cost.length>0)          ?[wineDetailsArray addObject:@[@"Cost",self.wine.costString]]:nil;
        (self.wine.dateBottled.length>0)   ?[wineDetailsArray addObject:@[@"Date Bottled",self.wine.dateBottled]]:nil;
        (self.wine.displayVariety.length>0)?[wineDetailsArray addObject:@[@"Grape Variety",self.wine.displayVariety]]:nil;
        (self.wine.alcoholContent.length>0)?[wineDetailsArray addObject:@[@"Alcoholic Content",self.wine.alcoholContent]]:nil;
        (self.wine.vineyard.length>0)      ?[wineDetailsArray addObject:@[@"Vineyard",self.wine.vineyard]]:nil;
        (self.wine.winemakers.length>0)    ?[wineDetailsArray addObject:@[@"Winemakers",self.wine.winemakers]]:nil;
        (self.wine.ph.length>0)            ?[wineDetailsArray addObject:@[@"pH",self.wine.ph]]:nil;
        (self.wine.closure.length>0)       ?[wineDetailsArray addObject:@[@"Closed Under",self.wine.closure]]:nil;
        _wineDetailsArray = [NSArray arrayWithArray:wineDetailsArray];
    }
    return _wineDetailsArray;
}

- (NSAttributedString *)wineDetailsAttributedString
{
    if (_wineDetailsAttributedString == nil) {
        
        NSMutableAttributedString * temp = [NSMutableAttributedString new];
        for (NSArray * wineDetail in self.wineDetailsArray) {
            NSAttributedString * detailTitle =
            [[NSAttributedString alloc] initWithString:[wineDetail[0] stringByAppendingString:@": \t"]
                                            attributes:@{NSFontAttributeName: [UIFont edmondsansRegularOfSize:14.0],
                                                         NSForegroundColorAttributeName: [UIColor wh_grey]}];
            NSAttributedString * detailString =
            [[NSAttributedString alloc] initWithString:[[wineDetail[1] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByAppendingString:@"\n"]
                                            attributes:@{NSFontAttributeName: [UIFont edmondsansBoldOfSize:14.0],
                                                         NSForegroundColorAttributeName: [UIColor wh_burgundy]}];
            [temp appendAttributedString:detailTitle];
            [temp appendAttributedString:detailString];
        }
        
        const CGFloat indent = 120.0;//width of 'Alcoholic Content'
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setFirstLineHeadIndent:0];
        [paragraphStyle setHeadIndent:indent];
        [paragraphStyle setLineSpacing:8.0];
        [paragraphStyle setTabStops:@[[[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft  location:indent options:nil]]];
        [temp addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, temp.length)];
        
        _wineDetailsAttributedString = temp;
    }
    return _wineDetailsAttributedString;
}

- (NSArray *)tastingNotesArray
{
    if (_tastingNotesArray == nil) {
        NSMutableArray * tastingNotesArray = @[].mutableCopy;
        (self.wine.colour.length>0)?[tastingNotesArray addObject:@[@"Colour:",self.wine.colour]]:nil;
        (self.wine.aroma.length>0) ?[tastingNotesArray addObject:@[@"Aroma:",self.wine.aroma]]:nil;
        (self.wine.palate.length>0)?[tastingNotesArray addObject:@[@"Palate:",self.wine.palate]]:nil;
        _tastingNotesArray = [NSArray arrayWithArray:tastingNotesArray];
    }
    return _tastingNotesArray;
}

#pragma mark Actions

- (void)_viewTastingNotesButtonTouchedUpInside:(UIButton *)button
{
    NSLog(@"%s", __func__);
    
    if (self.wine.pdfUrl.length > 0) {
        WHPDFViewController * pdfVC = [WHPDFViewController new];
        [pdfVC setPdfURL:[NSURL URLWithString:self.wine.pdfUrl]];
        [self.navigationController pushViewController:pdfVC animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kWineNoPDFAlertTitle", nil)
                                    message:NSLocalizedString(@"kWineNoPDFAlertMessage", nil)
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
    /*
    ((self.tastingNotesArray.count>0)?1:0)+
    ((self.wineDetailsArray.count>0)?1:0);
     */
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 3;
            break;
        case 1:
            return [self.tastingNotesArray count];
            /*
            (self.wine.colour?1:0)+
            (self.wine.aroma?1:0)+
            (self.wine.palate?1:0);
             */
            break;
        case 2:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if (self.wineRange.name == nil) {
                return 10.0;//padding
            }
            break;
        case 1:
            if ([self.tastingNotesArray count] <= 0)
                return 0.0;
            break;
        case 2:
            if ([self.wineDetailsArray count] <= 0)
                return 0.0;
        default:
            break;
    }
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [UIView new];
    
    UILabel * sectionHeaderLabel = [UILabel new];
    switch (section) {
        case 0: {
            [headerView setBackgroundColor:[UIColor whiteColor]];
            [sectionHeaderLabel setFont:[UIFont edmondsansMediumOfSize:20.0]];
            [sectionHeaderLabel setTextColor:[UIColor wh_burgundy]];
            
            if (self.rangeId != nil) {
                [sectionHeaderLabel setText:self.wineRange.name];
            } else {
                [sectionHeaderLabel setText:nil];
            }
        }
            break;
        case 1:
            [headerView setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:240.0/255.0 blue:235.0/255.0 alpha:1.0]];
            [sectionHeaderLabel setFont:[UIFont edmondsansRegularOfSize:18.0]];
            [sectionHeaderLabel setTextColor:[UIColor wh_grey]];
            [sectionHeaderLabel setText:@"Tasting Notes"];
            break;
        case 2:
            [headerView setBackgroundColor:[UIColor whiteColor]];
            [sectionHeaderLabel setFont:[UIFont edmondsansRegularOfSize:18.0]];
            [sectionHeaderLabel setTextColor:[UIColor wh_grey]];
            [sectionHeaderLabel setText:@"Wine Details"];
            break;
        default:
            break;
    }
    [headerView addSubview:sectionHeaderLabel];
    [sectionHeaderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0]];
    [headerView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                              toItem:headerView attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0
                                                            constant:10.0]];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0: {
                    WHWineCarouselCell * carouselCell = (WHWineCarouselCell*)[tableView dequeueReusableCellWithIdentifier:[WHWineCarouselCell reuseIdentifier]];
                    if (carouselCell.delegate != self && carouselCell.dataSource != self) {
                        [carouselCell setDelegate:self];
                        [carouselCell setDataSource:self];
                        [carouselCell reload]; //TODO - doesn't need to set offset?
                    } else {
                        [(id)carouselCell.carouselView reloadData];
                    }
                    return carouselCell;
                }
                    break;
                case 1:
                    return [tableView dequeueReusableCellWithIdentifier:[WHWineDescriptionCell reuseIdentifier]];
                    break;
                case 2:
                    return [tableView dequeueReusableCellWithIdentifier:[WHWineBuyShareCell reuseIdentifier]];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            return [tableView dequeueReusableCellWithIdentifier:[WHTastingNoteCell reuseIdentifier]];
            break;
        case 2:
            if (indexPath.row == 0) {
                return [tableView dequeueReusableCellWithIdentifier:[WHWineDetailCell reuseIdentifier]];
            } else {
                return [tableView dequeueReusableCellWithIdentifier:@"TastingNotesButtonCell"];
            }
            break;
        default:
            break;
    }
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return [WHWineCarouselCell cellHeight];
                    break;
                case 1:
                    return [WHWineDescriptionCell cellHeightForWineObject:self.wine] + 20.0;
                    break;
                case 2:
                    return [WHWineBuyShareCell cellHeight];
                    break;
                default:
                    break;
            }
        case 1: {
            NSArray * tastingNote = [self.tastingNotesArray objectAtIndex:indexPath.row];
            return [WHTastingNoteCell cellHeightForTitle:tastingNote[0] detail:tastingNote[1]];
        }
            break;
        case 2:
            if (indexPath.row == 0) {
                return [WHWineDetailCell cellHeightForAttributedString:self.wineDetailsAttributedString];
            } else {
                return 80.0; //tasting notes pdf cell.
            }
        default:
            break;
    }
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 1) {
                WHWineDescriptionCell * descriptionCell = (WHWineDescriptionCell*)cell;
                [descriptionCell setWine:self.wine];
                [descriptionCell setDelegate:self];
            }
            if (indexPath.row == 2) {
                WHWineBuyShareCell * buyShareCell = (WHWineBuyShareCell*)cell;
                [buyShareCell setBuyOnlineVisible:!([self.wine.website isEqualToString:[NSString string]] || self.wine.website == nil)];
                [buyShareCell setDelegate:(id)self];
            }
            
            break;
        case 1: {
            NSArray * tastingNote = [self.tastingNotesArray objectAtIndex:indexPath.row];
            WHTastingNoteCell * tastingNoteCell = (WHTastingNoteCell*)cell;
            [tastingNoteCell setTitle:tastingNote[0] detail:tastingNote[1]];
        }
            break;
        case 2:
            //indexPath.row == [self.wineDetailsArray count]
            if (indexPath.row == 0) {
                WHWineDetailCell * wineDetailCell = (WHWineDetailCell*)cell;
                [wineDetailCell.textLabel setAttributedText:self.wineDetailsAttributedString];
            } else {
                UIButton * pdfButton = (UIButton*)[cell.contentView viewWithTag:9999];
                [pdfButton setupBurgundyButtonWithBorderWidth:1.0 cornerRadius:2.0];
                
                [pdfButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
                [pdfButton addTarget:self action:@selector(_viewTastingNotesButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark WHWineCarouselCellDataSource

- (NSUInteger)numberOfWineObjectsInCell:(WHWineCarouselCell *)cell
{
    return [self.collectionManager.objects count];
}

- (WHWineMO *)cell:(WHWineCarouselCell *)cell wineObjectAtIndex:(NSUInteger)index
{
    if (index < self.collectionManager.objects.count) {
        return [self.collectionManager.objects objectAtIndex:index];
    } else {
        return nil;
    }
}

#pragma mark WHWineCarouselCellDelegate

- (void)cell:(WHWineCarouselCell *)cell currentWineIndexDidChange:(NSInteger)currentItemIndex
{
    NSArray * wines = self.collectionManager.objects;
    if (currentItemIndex != NSNotFound && wines.count > currentItemIndex) {
        WHWineMO * wine = nil;
        wine = [wines objectAtIndex:currentItemIndex];
        
        if ([self.selectedWineId isEqual:wine.wineId] == NO) {
            
            [self setSelectedWineId:wine.wineId];
            [self setWine:wine];
            
            [self.tableView beginUpdates];
            
            //Reload description & buy/sell cell.
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0],
                                                     [NSIndexPath indexPathForRow:2 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
            //Reload tasting & details sections...
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
        }
    }
}

#pragma mark 

- (void)wineDescriptionCell:(WHWineDescriptionCell *)cell didTapFavouriteButton:(UIButton *)button
{
//    BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineMO entityName]
//                                                identifier:[self.wine wineId]];
//    [button setSelected:didFavourite];
    
    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineMO entityName] identifier:[self.wine wineId]];
    if (favourite == nil) {
        AFNetworkReachabilityStatus reachability = [[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus];
        if (reachability == AFNetworkReachabilityStatusReachableViaWWAN || reachability == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHFavouriteAlertView" owner:nil options:nil];
            WHFavouriteAlertView * favouriteAlertView = [views firstObject];
            [favouriteAlertView setDelegate:(id)self];
            
            if ([WHFavouriteManager email] == nil) {
                [favouriteAlertView displayEmailEntry];
            }
            
            [WHAlertView presentView:favouriteAlertView animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoInternetAlertTitle", nil)
                                        message:NSLocalizedString(@"kFavouriteNoInternetAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    } else {
        BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineMO entityName] identifier:[self.wine wineId]];
        [button setSelected:didFavourite];
    }
    
}

- (void)wineDescriptionCell:(WHWineDescriptionCell *)cell didTapURL:(NSURL *)url
{
    WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrl:url];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark WHFavouriteAlertViewDelegate

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapOptOutButton:(UIButton *)button
{
    BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineMO entityName] identifier:self.wine.wineId];
    WHWineDescriptionCell * descriptionCell = (id)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    [descriptionCell.favouriteButton setSelected:didFavourite];
    
    [[WHAlertView currentAlertView] dismiss];
    
    if (self.wine.wineId != nil) {
        [[Mixpanel sharedInstance] track:@"Favourited Wine" properties:@{@"wine_id"  : self.wine.wineId,
                                                                         @"opted_out": @(YES)}];
    }
}

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapFavouriteButton:(UIButton *)button
{
    if ([WHFavouriteManager email] == nil) {
        if ([view.textField.text isEqualToString:[NSString string]] || view.textField.text == nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoEmailAlertTitle",nil)
                                        message:NSLocalizedString(@"kFavouriteNoEmailAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            return;
        } else {
            [view.textField resignFirstResponder];
            [WHFavouriteManager setEmail:view.textField.text];
        }
    }
    NSString * email = [WHFavouriteManager email];
    
    if (email != nil && self.wineryId != nil) {
        [PCDHUD show];
        
        __weak typeof(self) blockSelf = self;
        [WHFavouriteManager favouriteWineryId:self.wineryId
                                    withEmail:email
                                     callback:^(BOOL success, NSError *error) {
                                         if (success ) {
                                             [WHLoadingHUD dismiss];
                                             
                                             BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineMO entityName] identifier:blockSelf.wine.wineId];
                                             WHWineDescriptionCell * descriptionCell = (id)[blockSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                                             [descriptionCell.favouriteButton setSelected:didFavourite];
                                             
                                             //TODO - Implement shared WHAlertView getter
                                             WHAlertView * alertView = (WHAlertView*)view.superview;
                                             [alertView dismiss];

                                             if (blockSelf.wine.wineId != nil) {
                                                 [[Mixpanel sharedInstance] track:@"Favourited Wine" properties:@{@"wine_id": blockSelf.wine.wineId}];
                                             }

                                         } else {
                                             NSLog(@"Failed to add to mailing list: %@",error);
                                             [PCDHUD showError:error];
                                         }
                                     }];
    }
}

#pragma mark WHWineBuyShareCellDelegate

- (void)wineBuyShareCell:(WHWineBuyShareCell *)cell didSelectBuyOnlineButton:(UIButton *)button
{
    if (self.wine.wineId != nil) {
        [[Mixpanel sharedInstance] track:@"Buy Wine Online" properties:@{@"wine_id": self.wine.wineId}];
    }
    
    if (self.wine.website != nil) {
        WHWebViewController * wvc = [WHWebViewController webViewControllerWithUrlString:self.wine.website];
        UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:wvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)wineBuyShareCell:(WHWineBuyShareCell *)cell didSelectShareButton:(UIButton *)button
{
     _shareManager = [WHShareManager new];
    [_shareManager presentShareAlertWithObject:self.wine];
}

@end
