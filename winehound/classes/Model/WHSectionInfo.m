//
//  WHSectionInfo.m
//  WineHound
//
//  Created by Mark Turner on 28/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "WHSectionInfo.h"

@implementation WHSectionInfo

#pragma mark 
#pragma mark Init

- (id)initSectionTitle:(NSString *)title
          sectionImage:(UIImage *)sectionImage
{
    self = [super init];
    if (self) {
        _title = title;
        _image = sectionImage;
        _rowCount = 0;
        _identifier = -1;
        
        //TODO - have the section info maintain whether or not expanded...?
    }
    return self;
}

+ (WHSectionInfo *)sectionInfoWithSectionTitle:(NSString *)title
                                  sectionImage:(UIImage *)sectionImage
{
    return [[WHSectionInfo alloc] initSectionTitle:title sectionImage:sectionImage];
}

#pragma mark Getters
/*
- (NSInteger)rowCount
{
    if (self.expanded == YES) {
        return _rowCount;
    }
    return 0;
}
 */

@end
