//
//  WHEventCell.h
//  WineHound
//
//  Created by Mark Turner on 28/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WHEventMO;
@interface WHEventCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel     *locationLabel;

@property (nonatomic,weak) WHEventMO * event;

@end
