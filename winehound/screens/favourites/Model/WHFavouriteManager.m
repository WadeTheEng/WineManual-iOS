//
//  WHFavouriteManager.m
//  WineHound
//
//  Created by Mark Turner on 17/01/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "WHFavouriteManager.h"

static NSString * const kWHFavouritesEmailKey = @"WHFavouritesEmailKey";

@implementation WHFavouriteManager
//@dynamic email;

#pragma mark Email Property

+ (NSString *)email;
{
    NSString * email = [[NSUserDefaults standardUserDefaults] objectForKey:kWHFavouritesEmailKey];
    if (email.length <= 5) {
        return nil;
    }
    return email;
}

+ (void)setEmail:(NSString *)email;
{
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kWHFavouritesEmailKey];
}


#pragma mark

+ (void)favouriteWineryId:(NSNumber *)wineryId withEmail:(NSString *)email callback:(void(^)(BOOL success,NSError *error))callback
{
    [self favouriteKey:@"winery_id" withIdentifier:wineryId withEmail:email callback:callback];
}

+ (void)favouriteKey:(NSString *)key
      withIdentifier:(NSNumber *)identifier
           withEmail:(NSString *)email
            callback:(void(^)(BOOL success,NSError *error))callback;
{
    if (key == nil || identifier == nil || email == nil) {
        callback(NO,nil);
        return;
    }
    
    id params = @{@"mailing_list": @{@"email":email},key:identifier};
    
    NSMutableURLRequest * urlRequest = [[[RKObjectManager sharedManager] HTTPClient] requestWithMethod:@"POST" path:@"api/mailing_lists.json" parameters:params];
    AFJSONRequestOperation * mailingListOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Mailing success: %@",JSON);
        if (callback != nil) {
            callback(YES,nil);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Mailing failure: %@",JSON);
        
        NSString * errorString = nil;
        if ([JSON[@"errors"] isKindOfClass:[NSArray class]] && [(NSArray *)JSON[@"errors"] count] > 0) {
            errorString = [(NSArray *)JSON[@"errors"] objectAtIndex:0];
        } else {
            errorString = error.localizedDescription;
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        
        if (callback != nil) {
            callback(NO,error);
        }
    }];
    
    [[[RKObjectManager sharedManager] HTTPClient] enqueueHTTPRequestOperation:mailingListOperation];
}


@end
