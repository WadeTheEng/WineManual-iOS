//
//  WHCellarDoorCell.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class    WHWineryMO;
@protocol WHCellarDoorCellDelegate;

@interface WHCellarDoorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *cellarDoorInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *openingHoursTextView;
@property (weak, nonatomic) IBOutlet UIButton *readMoreButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic,weak) id <WHCellarDoorCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForWineryObject:(WHWineryMO *)winery;
+ (CGFloat)cellHeightForWineryObject:(WHWineryMO *)winery truncated:(BOOL)truncated;

- (void)setCellarDoorText:(NSString *)string;
- (void)setCellarDoorText:(NSString *)string truncated:(BOOL)truncated;

- (void)setOpeningHoursString:(NSAttributedString *)attrString;

@end

@protocol WHCellarDoorCellDelegate <NSObject>
- (void)cellarDoorCell:(WHCellarDoorCell *)cell didSelectReadMoreButton:(UIButton *)button;
- (void)cellarDoorCell:(WHCellarDoorCell *)cell didTapURL:(NSURL *)url;
@end