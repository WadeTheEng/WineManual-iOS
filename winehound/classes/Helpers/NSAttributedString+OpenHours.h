//
//  NSAttributedString+OpenHours.h
//  WineHound
//
//  Created by Mark Turner on 21/02/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WHOpenHoursProtocol <NSObject>

@required
- (NSSet *)openHoursSet;
- (NSString *)phoneNumber;
@optional
/*
 - (NSString *)timeZoneName;
*/
@end

@interface NSAttributedString (OpenHours)

+ (NSAttributedString *)openHoursAttributedStringWithObject:(NSObject <WHOpenHoursProtocol> *)object;

@end
