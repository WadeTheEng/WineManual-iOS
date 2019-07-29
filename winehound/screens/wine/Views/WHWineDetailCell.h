//
//  WHWineDetailCell.h
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHWineDetailCell : UITableViewCell

+ (CGFloat)cellHeightForAttributedString:(NSAttributedString *)attrString;

+ (NSString *)reuseIdentifier;

@end
