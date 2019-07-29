//
//  WHEventListCellView.m
//  WineHound
//
//  Created by Mark Turner on 22/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>

#import "WHEventListCellView.h"
#import "WHEventMO+Mapping.h"
#import "WHEventMO+Additions.h"
#import "WHPhotographMO+Mapping.h"

#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"
#import "NSCalendar+WineHound.h"

static __weak NSDateFormatter * _publicDateFormatter;

@interface WHEventListCellView ()
{
    __weak IBOutlet UILabel     *_eventTitleLabel;
    __weak IBOutlet UILabel     *_eventDateLabel;
    __weak IBOutlet UILabel     *_eventRegionLabel;
    __weak IBOutlet UIImageView *_eventImageView;
    __weak IBOutlet UIView      *_topSeperatorView;
    __weak IBOutlet UIActivityIndicatorView *_activityIndicatorView;
    
    __weak IBOutlet NSLayoutConstraint *_detailContainerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *_eventTitleLabelTopConstraint;

    __weak UIView * _selectedOverlayView;
    
    NSDateFormatter * _dateFormatter;
}
@property (nonatomic,weak) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic,weak) UIImageView             * eventImageView;
@property (nonatomic) NSCalendar * calendar;
@end

@implementation WHEventListCellView
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize eventImageView        = _eventImageView;


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
    return [UINib nibWithNibName:@"WHEventListCell" bundle:[NSBundle mainBundle]];
}

#pragma mark 
#pragma mark

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_eventTitleLabel  setFont:[UIFont edmondsansMediumOfSize:18.0]];
    [_eventDateLabel   setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [_eventRegionLabel setFont:[UIFont edmondsansRegularOfSize:14.0]];
    [_eventTitleLabel  setTextColor:[UIColor wh_grey]];
    [_eventDateLabel   setTextColor:[UIColor wh_grey]];
    [_eventRegionLabel setTextColor:[UIColor wh_grey]];

    [_activityIndicatorView setHidesWhenStopped:YES];

    UIView * selectedOverlayView = [UIView new];
    [selectedOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
    [selectedOverlayView setHidden:YES];
    [selectedOverlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView addSubview:selectedOverlayView];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[selectedOverlayView]|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(selectedOverlayView)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[selectedOverlayView]|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(selectedOverlayView)]];
    
    _selectedOverlayView = selectedOverlayView;
}

- (void)dealloc
{
    _dateFormatter = nil;
    _calendar = nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self setEvent:nil];
    [self setTopSeperatorHidden:NO];
}

#pragma mark
#pragma mark

- (void)setEvent:(WHEventMO *)event
{
    _event = event;

    [_eventTitleLabel setText:event.name];
    [_eventDateLabel  setText:event.datePeriodString];
    [_eventImageView setImage:nil];
    
    if (event.regions.count > 0) {
        NSObject * region = [event.regions anyObject];//prioritise by distance?
        [_eventRegionLabel setText:[region valueForKey:@"name"]];
        [_detailContainerHeightConstraint setConstant:80.0];
        [_eventTitleLabelTopConstraint setConstant:8.0];
    } else {
        [_eventRegionLabel setText:nil];
        [_detailContainerHeightConstraint  setConstant:70.0];
        [_eventTitleLabelTopConstraint setConstant:11.0];
    }
    
    if (event.featured.boolValue == YES && event.photographs.count > 0) {
        WHPhotographMO * photograph = [event.photographs firstObject];
        
        [_activityIndicatorView startAnimating];

        NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:photograph.imageThumbURL]];
        [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __weak typeof (self) weakSelf = self;
        [_eventImageView setImageWithURLRequest:imageRequest
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            if (image != nil && request == nil) {
                                                //Returned with cached image & should already be decoded.
                                                [weakSelf.activityIndicatorView stopAnimating];
                                                [weakSelf.eventImageView setImage:image];
                                            } else {
                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                                    UIGraphicsBeginImageContext(CGSizeMake(1,1));
                                                    CGContextRef context = UIGraphicsGetCurrentContext();
                                                    CGContextDrawImage(context, (CGRect){0,0,1,1}, [image CGImage]);
                                                    UIGraphicsEndImageContext();
                                                    
                                                    if ([imageRequest isEqual:request]) {
                                                        dispatch_sync(dispatch_get_main_queue(), ^{
                                                            [weakSelf.activityIndicatorView stopAnimating];
                                                            [weakSelf.eventImageView setImage:image];
                                                        });
                                                    }
                                                });
                                            }
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            if ([imageRequest isEqual:request]) {
                                                [weakSelf.activityIndicatorView stopAnimating];
                                                [weakSelf.eventImageView setImage:nil];
                                            }
                                        }];
    }
}

- (void)setTopSeperatorHidden:(BOOL)hidden
{
    [_topSeperatorView setHidden:hidden];
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

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil) {
        if (_publicDateFormatter == nil) {
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"]];
            [dateFormatter setDateFormat:@"EEEE dd MMM, YYYY"];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            _publicDateFormatter = dateFormatter;
            _dateFormatter = dateFormatter;
        }
        _dateFormatter = _publicDateFormatter;
    }
    return _dateFormatter;
}

- (NSCalendar *)calendar
{
    if (_calendar == nil) {
        _calendar = [NSCalendar wh_sharedCalendar];
    }
    return _calendar;
}

@end
