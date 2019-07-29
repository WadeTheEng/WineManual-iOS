//
//  NSAttributedString+HTML.h
//  WineHound
//
//  Created by Mark Turner on 14/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (HTML)

/*
 Returns a NSAttributedString with default Winehound font, size & colour
 */
+ (NSAttributedString *)wh_attributedStringWithHTMLString:(NSString *)string;

@end
