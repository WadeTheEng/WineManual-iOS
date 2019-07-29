//
//  WHEventsTableCell.m
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHEventsTableCell.h"
#import "WHEventCell.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

static NSString * const kCollectionViewEventCell = @"CollectionViewEventCell";

@interface WHEventsTableCell ()
<UICollectionViewDelegate,UICollectionViewDataSource>
@end

@implementation WHEventsTableCell

#pragma mark
#pragma mark

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:[self reuseIdentifier] bundle:[NSBundle mainBundle]];
}

#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];

    UINib * collectionEventCellNib = [UINib nibWithNibName:@"WHEventCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:collectionEventCellNib forCellWithReuseIdentifier:kCollectionViewEventCell];
    [self.collectionView setContentInset:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0)];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];

    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    
    [self.activityIndicator setHidesWhenStopped:YES];
    
    [self.noEventsLabel setHidden:YES];
    [self.noEventsLabel setFont:[UIFont edmondsansRegularOfSize:17.0]];
    [self.noEventsLabel setTextColor:[UIColor wh_grey]];
}

+ (CGFloat)cellHeight
{
    return 200.0;
}

+ (CGFloat)featuredCellHeight
{
    return 250.0;
}

- (void)reload
{
    [self.collectionView reloadData];
}

#pragma mark
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfEventsInEventsCell:)]) {
        return [self.dataSource numberOfEventsInEventsCell:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WHEventCell * eventCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewEventCell forIndexPath:indexPath];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(eventsCell:eventObjectForIndex:)]) {
        WHEventMO * eventObject = [self.dataSource eventsCell:self eventObjectForIndex:indexPath.row];
        [eventCell setEvent:eventObject];
    }
    return eventCell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(0.6 * CGRectGetHeight(collectionView.frame), CGRectGetHeight(collectionView.frame) - 30.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s", __func__);
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(eventsCell:didSelectEventAtIndex:)]) {
        [self.delegate eventsCell:self didSelectEventAtIndex:indexPath.row];
    }
}

@end
