//
//  NSString+Empty.m
//  WineHound
//
//  Created by Mark Turner on 21/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSString+Empty.h"

@implementation NSString (Empty)

- (BOOL)isEmpty
{
    //whitespaceCharacterSet
    return ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0);
}

@end
