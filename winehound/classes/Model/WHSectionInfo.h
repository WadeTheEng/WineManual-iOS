//
//  WHSectionInfo.h
//  WineHound
//
//  Created by Mark Turner on 28/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHSectionInfo : NSObject

@property (nonatomic,readonly) NSString * title;
@property (nonatomic,readonly) UIImage  * image;

@property (nonatomic) NSInteger rowCount;
@property (nonatomic) NSInteger identifier;

+ (WHSectionInfo *)sectionInfoWithSectionTitle:(NSString *)title
                                  sectionImage:(UIImage *)sectionImage;

@end
