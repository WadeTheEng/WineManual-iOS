//
//  WHShareProtocol.h
//  WineHound
//
//  Created by Mark Turner on 31/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WHShareProtocol <NSObject>
@required

- (NSString *)shareTitle;

- (NSString *)facebookShareString;
- (NSString *)twitterShareString;
- (NSString *)smsShareString;

- (id)trackProperties;//Mix panel properties

@optional
- (NSString *)emailSubject;
- (NSString *)emailBody;

@end
