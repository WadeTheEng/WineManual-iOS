//
//  WHEventButtonsCell.h
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHEventButtonsCellDelegate;

@interface WHEventButtonsCell : UITableViewCell
{
    __weak IBOutlet UIButton *_websiteButton;
    __weak IBOutlet UIButton *_calendarButton;
}
@property (nonatomic,weak) id <WHEventButtonsCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;
+ (CGFloat)cellHeight;

@end

@protocol WHEventButtonsCellDelegate <NSObject>
- (void)eventButtonCell:(WHEventButtonsCell *)cell didTapWebsiteButton:(UIButton *)button;
- (void)eventButtonCell:(WHEventButtonsCell *)cell didTapCalendarButton:(UIButton *)button;
@end
