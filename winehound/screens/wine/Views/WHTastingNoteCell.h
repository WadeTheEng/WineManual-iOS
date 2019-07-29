//
//  WHTastingNoteCell.h
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHTastingNoteCell : UITableViewCell
{
    __weak IBOutlet UILabel *_tastingTitleLabel;
    __weak IBOutlet UILabel *_tastingDescriptionLabel;
}
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeightForTitle:(NSString *)title detail:(NSString *)detail;
- (void)setTitle:(NSString *)title detail:(NSString *)detail;
@end