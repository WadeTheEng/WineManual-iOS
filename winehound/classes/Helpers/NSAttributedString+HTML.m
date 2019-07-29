//
//  NSAttributedString+HTML.m
//  WineHound
//
//  Created by Mark Turner on 14/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSAttributedString+HTML.h"
#import "UIFont+Edmondsans.h"
#import "UIColor+WineHoundColors.h"

@implementation NSAttributedString (HTML)

+ (NSAttributedString *)wh_attributedStringWithHTMLString:(NSString *)string
{
    size_t numComponents = CGColorGetNumberOfComponents([[UIColor wh_grey] CGColor]);
    
    NSAssert(numComponents == 4 || numComponents == 2, @"Unsupported color format");
    
    // E.g. FF00A5
    NSString *colorHexString = nil;
    const CGFloat *components = CGColorGetComponents([[UIColor wh_grey] CGColor]);
    if (numComponents == 4) {
        unsigned int red = components[0]   * 255;
        unsigned int green = components[1] * 255;
        unsigned int blue = components[2]  * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", red, green, blue];
    } else {
        unsigned int white = components[0] * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", white, white, white];
    }
    
    NSString * htmlString = [NSString stringWithFormat:@"<html>\n"
                             "<head>\n"
                             "<style type=\"text/css\">\n"
                             "body {font-family: \"%@\"; font-size: %@; color:#%@;}\n"
                             "</style>\n"
                             "</head>\n"
                             "<body>%@</body>\n"
                             "</html>",
                             @"Edmondsans", @(14.0), colorHexString, string];
    
    NSError * error = nil;
    NSMutableAttributedString * attributedString = nil;
    attributedString = [[NSMutableAttributedString alloc]
                        initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding]
                        options:@{NSDocumentTypeDocumentAttribute:       NSHTMLTextDocumentType,
                                  NSCharacterEncodingDocumentAttribute:@(NSUTF8StringEncoding)}
                        documentAttributes:NULL
                        error:&error];
    
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:0
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
                                  if (value) {
                                      NSParagraphStyle * paragraphStyle = (NSParagraphStyle *)value;
                                      if (paragraphStyle.lineSpacing < 4.0) {
                                          NSMutableParagraphStyle * mutableCopy = [paragraphStyle mutableCopy];
                                          [mutableCopy setLineSpacing:4.0];
                                          
                                          [attributedString removeAttribute:value range:range];
                                          [attributedString addAttribute:NSParagraphStyleAttributeName value:mutableCopy range:range];
                                      }
                                  }
                              }];
    
    [attributedString enumerateAttribute:NSFontAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:0
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
                                  if (value) {
                                      UIFont * originalFont = (UIFont *)value;
                                      if (originalFont.pointSize < 14.0) {
                                          [attributedString removeAttribute:value range:range];
                                          [attributedString addAttribute:NSFontAttributeName value:[originalFont fontWithSize:14.0] range:range];
                                      }
                                  }
                              }];
    
    return attributedString;
}

@end
