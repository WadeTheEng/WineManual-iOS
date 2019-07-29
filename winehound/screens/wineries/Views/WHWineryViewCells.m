//
//  WHWineryViewCells.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHWineryViewCells.h"
#import "WHWineryMO.h"
#import "UIColor+WineHoundColors.h"
#import "UIFont+Edmondsans.h"
#import "WHAmenityMO+Additions.h"
#import "WHWineryMO+Additions.h"

@interface WHAmenityCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
+ (NSString *)reuseIdentifier;
@end

@interface WHWineryNormalViewCell () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) SWUtilityButtonView *scrollViewButtonViewRight;
@end

@implementation WHWineryNormalViewCell
@dynamic scrollViewButtonViewRight;

/*
#pragma mark

- (NSNumberFormatter *)distanceNumberFormatter
{
    NSNumberFormatter * numberFormatter = nil;
    
    if (_publicDistanceNumberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@"0.## km"];
        _publicDistanceNumberFormatter = numberFormatter;
    } else {
        numberFormatter = _publicDistanceNumberFormatter;
    }
    
    _distanceNumberFormatter = numberFormatter;
    numberFormatter = nil;
    
    return _distanceNumberFormatter;
}

- (void)dealloc
{
    _distanceNumberFormatter = nil;
}

*/

#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_wineryNameLabel     setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:_wineryNameLabel.font.pointSize]];
    [_wineryDistanceLabel setFont:[UIFont fontWithName:@"Edmondsans-Regular" size:_wineryDistanceLabel.font.pointSize]];
    
    [_listingsCollectionView registerClass:[WHAmenityCell class] forCellWithReuseIdentifier:[WHAmenityCell reuseIdentifier]];
    [_listingsCollectionView setBackgroundColor:[UIColor clearColor]];
    [_listingsCollectionView setScrollsToTop:NO];
    
    [_listingsCollectionView setDataSource:self];
    [_listingsCollectionView setDelegate:self];

    UIView * selectedOverlayView = [UIView new];
    [selectedOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
    [selectedOverlayView setHidden:YES];
    [selectedOverlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:selectedOverlayView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectedOverlayView]|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(selectedOverlayView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectedOverlayView]-7-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(selectedOverlayView)]];
    _selectedOverlayView = selectedOverlayView;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setWinery:nil];
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle mainBundle]];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

+ (CGFloat)cellHeight
{
    return 80.0;
}

- (void)setWinery:(WHWineryMO *)winery
{
    _winery = winery;
    [_wineryNameLabel setText:_winery.name];
    [_wineryDistanceLabel setText:nil];
    
    if (winery.tierValue < WHWineryTierBasic) {
        [_listingsCollectionView reloadData];
        [_listingsCollectionView setHidden:NO];
    } else {
        [_listingsCollectionView setHidden:YES];
    }
}

- (void)setDistance:(CLLocationDistance)distance
{
    //distance in meters.
    _distance = distance;
    
    CGFloat kilometer = (_distance/1000.0);
    if (kilometer > 1.0) {
        [_wineryDistanceLabel setText:[NSString stringWithFormat:@"%.0f km",kilometer]];
    } else {
        [_wineryDistanceLabel setText:[NSString stringWithFormat:@"%.2f km",kilometer]];
    }
}

- (void)setDistanceLabelHidden:(BOOL)hidden
{
    [_wineryDistanceLabel setHidden:hidden];
}
    
- (void)displaySwipeButtons:(BOOL)display
{
    if (display == YES) {
        UIButton * shareButton = [UIButton new];
        [shareButton setTitle:@"Share" forState:UIControlStateNormal];
        [shareButton setBackgroundColor:[UIColor wh_grey]];
        [shareButton.titleLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
        
        UIButton * deleteButton = [UIButton new];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [deleteButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
        [deleteButton.titleLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
        
        [self setRightUtilityButtonStyle:SWUtilityButtonStyleVertical];
        [self setRightUtilityButtons:@[shareButton,deleteButton]];
    } else {
        [self setRightUtilityButtons:nil];
    }
}

#pragma mark UITableViewCell

- (void)setSelected:(BOOL)selected
{
    [_selectedOverlayView setHidden:!selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [_selectedOverlayView setHidden:!selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [_selectedOverlayView setHidden:!highlighted];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [_selectedOverlayView setHidden:!highlighted];
}


#pragma mark
#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    [collectionView.collectionViewLayout invalidateLayout];
    return MIN([self.winery.amenities count], 4);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WHAmenityCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:[WHAmenityCell reuseIdentifier] forIndexPath:indexPath];
    WHAmenityMO * amenityObject = [self.winery.amenities objectAtIndex:indexPath.row];
    [cell.imageView setImage:[amenityObject icon]];
    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(25.0, 25.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0;
}



@end

////

@implementation WHAmenityCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        UIImageView * iv = [UIImageView new];
        [iv setContentMode:UIViewContentModeScaleAspectFit];
        [iv setTintColor:[UIColor wh_grey]];
        [self.contentView addSubview:iv];
        _imageView = iv;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_imageView setFrame:CGRectMake(.0, .0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_imageView setImage:nil];
}

@end

////

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PCGradientView.h"
#import "WHPhotographMO.h"

@interface WHWineryPremiumViewCell ()
@property (nonatomic,weak) UIActivityIndicatorView * activityIndicator;
@property (nonatomic,weak) UIImageView             * wineryImageView;
@end

@implementation WHWineryPremiumViewCell

#pragma mark - 

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_gradientView setBackgroundColor:[UIColor clearColor]];
    [(CAGradientLayer*)[_gradientView layer] setColors:@[(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor,
                                                         (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                                         (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor]];
    
    /*
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    [effectX setMinimumRelativeValue:@(-10.0)];
    [effectX setMaximumRelativeValue:@(10.0)];
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    [effectY setMinimumRelativeValue:@(-10.0)];
    [effectY setMaximumRelativeValue:@(10.0)];
    
    [_wineryImageView addMotionEffect:effectX];
    [_wineryImageView addMotionEffect:effectY];
     */
    [_wineryImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_wineryImageView setClipsToBounds:YES];
    
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.contentView insertSubview:activityIndicator aboveSubview:_wineryImageView];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_wineryImageView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_wineryImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    _activityIndicator = activityIndicator;
}

- (void)setWinery:(WHWineryMO *)winery
{
    [super setWinery:winery];
    
    if (winery == nil) {
        [self.wineryImageView setImage:nil];
    } else {
        WHPhotographMO * photograph = [winery.photographs firstObject];
        if (photograph == nil) {
            [self.wineryImageView setImage:[UIImage imageNamed:@"winery_placeholder"]];
        } else {
            
            NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageThumbURL]];
            [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
            
            [_activityIndicator startAnimating];
            
            __weak typeof(self) blockSelf = self;
            [self.wineryImageView setImage:nil];
            [self.wineryImageView setImageWithURLRequest:imageRequest
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                     if (image != nil && request == nil) {
                                                         //Returned with cached image & should already be decoded.
                                                         [blockSelf.activityIndicator stopAnimating];
                                                         [blockSelf.wineryImageView setImage:image];
                                                     } else {
                                                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                             UIGraphicsBeginImageContext(CGSizeMake(1,1));
                                                             CGContextRef context = UIGraphicsGetCurrentContext();
                                                             CGContextDrawImage(context, (CGRect){0,0,1,1}, [image CGImage]);
                                                             UIGraphicsEndImageContext();
                                                             if ([imageRequest isEqual:request]) {
                                                                 dispatch_sync(dispatch_get_main_queue(), ^{
                                                                     [blockSelf.activityIndicator stopAnimating];
                                                                     [blockSelf.wineryImageView setImage:image];
                                                                 });
                                                             }
                                                         });
                                                     }
                                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                     if ([imageRequest isEqual:request]) {
                                                         [blockSelf.activityIndicator stopAnimating];
                                                     }
                                                 }];
        }
    }
}

+ (CGFloat)cellHeight
{
    return 210.0;
}

@end
