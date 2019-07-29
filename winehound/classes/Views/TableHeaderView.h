//
//  TableHeaderView.h
//  WineHound
//
//  Created by Mark Turner on 09/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCGradientView;
@interface TableHeaderView : UIView {
@private
    PCGradientView * _gradientView;
}
@property (weak, nonatomic) UICollectionView *galleryCollectionView;
@property (weak, nonatomic) UILabel          *titleLabel;
@property (weak, nonatomic) UIButton         *favouriteButton;
@property (weak, nonatomic) UILabel          *imageIndicatorLabel;
@property (weak, nonatomic) UIButton         *weatherInfoButton;
@property (nonatomic) NSInteger imageIndicatorPosition; //0 top right, 1 top left
- (void)setOffset:(CGFloat)offset;
- (void)setPageNumber:(NSInteger)pageNumber;
- (void)reload;
@end

/////

@interface WHGalleryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
+ (NSString *)reuseIdentifier;
- (void)downloadImage:(NSURL *)imageURL;
@end
