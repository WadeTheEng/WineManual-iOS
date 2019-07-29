//
//  NSString+ReformatTel.m
//  WineHound
//
//  Created by Mark Turner on 07/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "NSString+ReformatTel.h"

@implementation NSString (ReformatTel)

- (NSString *)escaped
{
    NSString * number = self;
    
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet new];
    [charSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    [charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    [charSet formUnionWithCharacterSet:[NSCharacterSet symbolCharacterSet]];
    
    NSArray *arrayWithNumbers = [number componentsSeparatedByCharactersInSet:charSet];
    NSString *cleanedString = [arrayWithNumbers componentsJoinedByString:@""];
    NSString *escaped = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return escaped;
}

@end
