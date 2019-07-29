//
//  WHHelpers.m
//  WineHound
//
//  Created by Mark Turner on 06/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "WHHelpers.h"
#import "NSAttributedString+HTML.h"

NSString * TruncatedString(NSString * string,NSUInteger limit) {
    NSRange stringRange = {0, MIN([string length], limit)};
    NSString * shortString = [string substringWithRange:stringRange];
    if ([string length] > stringRange.length) {
        shortString = [shortString stringByAppendingString:@"..."];
    }
    return shortString;
}

NSAttributedString * TruncatedAttributedString(NSAttributedString * attributedString,NSUInteger limit,BOOL * didTruncate) {
    NSRange truncatedStringRange = {0, MIN([attributedString length], limit)};

    NSAttributedString * truncatedString = attributedString;
    if ([attributedString length] > truncatedStringRange.length) {
        NSMutableAttributedString * mutableCopy = [attributedString mutableCopy];
        
        NSDictionary * attributes = [mutableCopy attributesAtIndex:mutableCopy.length-1 effectiveRange:nil];
        NSAttributedString * dotdotdot = [[NSAttributedString alloc] initWithString:@"..." attributes:attributes];
        
        [mutableCopy replaceCharactersInRange:NSMakeRange(limit, mutableCopy.length - limit) withAttributedString:dotdotdot];

        * didTruncate = YES;
        truncatedString = (id)mutableCopy;
    }
    return truncatedString;
}