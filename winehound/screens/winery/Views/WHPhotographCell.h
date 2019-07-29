//
//  WHPhotographCell.h
//  WineHound
//
//  Created by Mark Turner on 28/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class    WHPhotographMO;
@protocol WHPhotographCellDelegate;

@interface WHPhotographCell : UITableViewCell

@property (readonly, nonatomic) UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) CGFloat downloadProgress;

@property (nonatomic,weak) WHPhotographMO * photograph;
@property (nonatomic,weak) id <WHPhotographCellDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (UINib *)nib;

@end

@protocol WHPhotographCellDelegate <NSObject>
- (void)photographCellDidTouchUpInside:(WHPhotographCell *)cell;
@end