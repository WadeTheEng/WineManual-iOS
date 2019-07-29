//
//  WHWineBuyShareCell.h
//  WineHound
//
//  Created by Mark Turner on 03/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHWineBuyShareCellDelegate;
@interface WHWineBuyShareCell : UITableViewCell
{
    __weak IBOutlet UIButton * _buyOnlineButton;
    __weak IBOutlet UIButton * _shareWineButton;
}
@property (nonatomic,weak) id <WHWineBuyShareCellDelegate> delegate;
@property (nonatomic) BOOL buyOnlineVisible;
+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;
@end

@protocol WHWineBuyShareCellDelegate <NSObject>
- (void)wineBuyShareCell:(WHWineBuyShareCell *)cell didSelectBuyOnlineButton:(UIButton *)button;
- (void)wineBuyShareCell:(WHWineBuyShareCell *)cell didSelectShareButton:(UIButton *)button;
@end