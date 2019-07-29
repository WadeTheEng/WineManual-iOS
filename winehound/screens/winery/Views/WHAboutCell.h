//
//  WHAboutCell.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class    WHWineryMO,WHRegionMO,WHEventMO;
@protocol WHAboutCellDelegate;

@interface WHAboutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;
@property (weak, nonatomic) IBOutlet UIButton *readMoreButton;
@property (weak, nonatomic) WHEventMO * event;

@property (nonatomic,weak) id <WHAboutCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForAboutText:(NSString *)string   truncated:(BOOL)truncated;//can pass HTML string
+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event truncated:(BOOL)truncated;

- (void)setAboutText:(NSString *)string;
- (void)setAboutText:(NSString *)string truncated:(BOOL)truncated;
- (void)setEvent:(WHEventMO *)event truncated:(BOOL)truncated;

@end


@protocol WHAboutCellDelegate <NSObject>
- (void)aboutCell:(WHAboutCell *)cell didTapReadMoreButton:(UIButton *)button;
- (void)aboutCell:(WHAboutCell *)cell didTapURL:(NSURL *)url;
@end