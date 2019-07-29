//
//  WHEventListCellView.h
//  WineHound
//
//  Created by Mark Turner on 22/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell/SWTableViewCell.h>

@class WHEventMO;
@interface WHEventListCellView : SWTableViewCell
@property (nonatomic,weak) WHEventMO * event;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

- (void)setTopSeperatorHidden:(BOOL)hidden;
- (void)displaySwipeButtons:(BOOL)display;

@end
