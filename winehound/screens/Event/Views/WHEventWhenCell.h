//
//  WHEventWhenCell.h
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHEventMO;
@interface WHEventWhenCell : UITableViewCell
{
    __weak IBOutlet UILabel *_whenLabel;
    __weak IBOutlet UILabel *_dateLabel;
    __weak IBOutlet UILabel *_timeLabel;
    __weak IBOutlet UILabel *_whereLabel;
    __weak IBOutlet UILabel *_locationLabel;
}
@property (nonatomic,weak) WHEventMO * event;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event;

@end
