//
//  UIViewController+Favourite.m
//  WineHound
//
//  Created by Mark Turner on 25/06/2014.
//  Copyright (c) 2014 Papercloud. All rights reserved.
//

#import "UIViewController+Favourite.h"
#import "WHFavouriteManager.h"
#import "WHFavouriteAlertView.h"
#import "WHFavouriteMO+Additions.h"
#import "WHAlertView.h"
#import "WHLoadingHUD.h"

#import <objc/runtime.h>

static char kWHMailingIdentiferKey;
static char kWHFavouriteIdentifierKey;

@implementation UIViewController (Favourite)

- (BOOL)displayFavouriteAlertForEntity:(NSString *)entityName
                        withIdentifier:(NSNumber *)identifier
                     mailingIdentifier:(NSString *)mailingIdentifier

{
    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:entityName
                                                            identifier:identifier];
    
    if (favourite == nil) {

        AFNetworkReachabilityStatus reachability = [[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus];

        if (reachability == AFNetworkReachabilityStatusReachableViaWWAN ||
            reachability == AFNetworkReachabilityStatusReachableViaWiFi) {

            WHFavouriteAlertView * favouriteAlertView = [WHFavouriteAlertView new];
            [favouriteAlertView setDelegate:(id)self];

            if ([WHFavouriteManager email] == nil) {
                [favouriteAlertView displayEmailEntry];
            }
            
            objc_setAssociatedObject(self, &kWHMailingIdentiferKey,mailingIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(self, &kWHFavouriteIdentifierKey, identifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
            
            [WHAlertView presentView:favouriteAlertView animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoInternetAlertTitle", nil)
                                        message:NSLocalizedString(@"kFavouriteNoInternetAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }

        return NO;

    } else {
        return ! [WHFavouriteMO favouriteEntityName:entityName
                                        identifier:identifier];
    }
}


#pragma mark
#pragma mark WHFavouriteAlertViewDelegate

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapOptOutButton:(UIButton *)button
{
    NSLog(@"%s", __func__);
}

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapFavouriteButton:(UIButton *)button
{
    if ([WHFavouriteManager email] == nil) {
        if ([view.textField.text isEqualToString:[NSString string]] || view.textField.text == nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoEmailAlertTitle",nil)
                                        message:NSLocalizedString(@"kFavouriteNoEmailAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            return;
        } else {
            [view.textField resignFirstResponder];
            [WHFavouriteManager setEmail:view.textField.text];
        }
    }
    NSString * email = [WHFavouriteManager email];
    
    if (email != nil) {
        
        [PCDHUD show];
        
        NSString * mailingIdentifier   = objc_getAssociatedObject(self, &kWHMailingIdentiferKey);
        NSNumber * favouriteIdentifier = objc_getAssociatedObject(self, &kWHFavouriteIdentifierKey);
        
        if (mailingIdentifier && favouriteIdentifier) {
            NSLog(@"mailingIdentifier: %@ - favouriteIdentifier: %@",mailingIdentifier,favouriteIdentifier);
        }

        __weak typeof(self) weakSelf = self;
        
        [WHFavouriteManager favouriteKey:mailingIdentifier
                          withIdentifier:favouriteIdentifier
                               withEmail:nil
                                callback:^(BOOL success, NSError *error) {
                                    if (success ) {
                                        [WHLoadingHUD dismiss];
                                        
                                        /*

                                        BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName] identifier:blockSelf.wineryId];
                                        [blockSelf.tableHeaderView.favouriteButton setSelected:didFavourite];
                                        
                                        //TODO - Implement shared WHAlertView getter
                                        WHAlertView * alertView = (WHAlertView*)view.superview;
                                        [alertView dismiss];
                                       
                                        if (blockSelf.wineryId != nil) {
                                            [[Mixpanel sharedInstance] track:@"Favourited Winery" properties:@{@"winery_id": blockSelf.wineryId}];
                                        }
                                         */
                                        
                                    } else {
                                        NSLog(@"Failed to add to mailing list: %@",error);
                                        [PCDHUD showError:error];
                                    }
                                }];
    }
}


@end
