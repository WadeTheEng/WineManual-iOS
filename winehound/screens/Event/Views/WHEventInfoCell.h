//
//  WHEventInfoCell.h
//  WineHound
//
//  Created by Mark Turner on 20/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHEventMO;
@interface WHEventInfoCell : UITableViewCell
{
    __weak IBOutlet UITextView *_descriptionTextView;
}
@property (nonatomic,weak) WHEventMO * event;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

+ (CGFloat)cellHeightForEventObject:(WHEventMO *)event;

@end
