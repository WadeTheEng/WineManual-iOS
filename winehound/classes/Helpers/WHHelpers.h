//
//  WHHelpers.h
//  WineHound
//
//  Created by Mark Turner on 06/12/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * TruncatedString(NSString * string,NSUInteger limit);
NSAttributedString * TruncatedAttributedString(NSAttributedString * attributedString,NSUInteger limit,BOOL * didTruncate);
