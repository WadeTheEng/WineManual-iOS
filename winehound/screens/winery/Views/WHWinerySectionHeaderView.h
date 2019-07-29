//
//  WHWinerySectionHeaderView.h
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHWinerySectionHeaderViewDelegate;

@interface WHWinerySectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) UIImageView *sectionImageView;
@property (weak, nonatomic) UILabel     *sectionTitleLabel;
@property (weak, nonatomic) UILabel     *sectionDetailLabel;
@property (weak, nonatomic) UIImageView *sectionAccesoryView;

@property (nonatomic) CGFloat titleLabelLeftInset;
@property (nonatomic) NSUInteger section;
@property (nonatomic,weak) id <WHWinerySectionHeaderViewDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (CGFloat)viewHeight;

- (void)setExpanded:(BOOL)expanded animationDuration:(NSTimeInterval)animationDuration;

@end

@protocol WHWinerySectionHeaderViewDelegate <NSObject>
- (void)didSelectTableViewHeaderSection:(WHWinerySectionHeaderView *)headerView;
@end
