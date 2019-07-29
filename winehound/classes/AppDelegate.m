//
//  AppDelegate.m
//  WineHound
//
//  Created by Tomas Spacek on 26/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import "AppDelegate.h"
#import <MMDrawerController/MMDrawerController.h>
#import <GoogleMaps/GoogleMaps.h>
#import <RestKit/RestKit.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <BugSense-iOS/BugSenseController.h>
#import <Instabug/Instabug.h>
#import <forecast-ios-api/Forecast.h>
#import <FacebookSDK/FBSettings.h>
#import <FacebookSDK/FBAppEvents.h>
#import <TestFlightSDK/TestFlight.h>
#import <PCDefaults/PCDOperationTracker.h>
#import <PCDefaults/PCDHUD.h>

#import "WHRootViewController.h"
#import "WHOnboardingViewController.h"
#import "WHSplashViewController.h"
#import "WHWineryViewController.h"
#import "WHWineriesScheduledLocationManager.h"

#import "WHPhotographMO.h"
#import "WHWineryMO.h"

#import "RKManagedObjectStore+PCExtensions.h"
#import "RKManagedObjectStore+MagicalRecord.h"
#import "WHRestKitSetup.h"
#import "WHDummyData.h"
#import "WHApperance.h"
#import "Constants.h"

#import "UIColor+WineHoundColors.h"
#import "WHLoadingHUD.h"
#import "AppTracker.h"

static NSString * const kWHAppLaunchCount = @"WHAppLaunchCount";
static NSString * const kWHLastResignTime = @"WHLastResignTime";

@interface AppDelegate () <WHOnboardingViewControllerDelegate>
@property (nonatomic,strong) WHWineriesScheduledLocationManager * scheduledLocationManager;
@property (nonatomic,strong) UIWindow * splashWindow;
@property (nonatomic,strong) UIWindow * onboardingWindow;

@end

@implementation AppDelegate

/*
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
*/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{kWHUserDefaultsPushEnabled: @(YES)}];
    [defaults synchronize];
    
    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*8
                                                         diskCapacity:1024*1024*256
                                                             diskPath:@"AFNetworking"];
    [NSURLCache setSharedURLCache:urlCache];
    
    /*
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:kPCRKExtensionsStoreName];
    [[NSFileManager defaultManager] removeItemAtPath:storePath error:nil];
     
     [WHDummyData setupHTTPStubs];
     */
    
    [GMSServices provideAPIKey:kGMSAPIKey];
    [[Forecast sharedInstance] initializeWithApiKey:kForecastIOAPIKey];
    [AppTracker startSession:kAppFireworksAPIKey];

#ifdef ADHOC
    [TestFlight takeOff:kTestFlightAPI];//Check if release version...?
#endif

#ifndef DEBUG
    [Instabug setIsTrackingLocation:NO];
    [Instabug startWithToken:kInstabugToken
               captureSource:IBGCaptureSourceUIKit
             invocationEvent:IBGInvocationEventShake];
    [Instabug setIsTrackingUserSteps:NO];
    [Instabug setEmailIsRequired:NO];
    [Instabug setCommentIsRequired:NO];
    [Instabug setColorTheme:IBGColorThemeGrey];
    [Instabug setHeaderFontColor:[UIColor wh_burgundy]];
    [Instabug setButtonsColor:[UIColor wh_burgundy]];
    [Instabug setTextFontColor:[UIColor wh_burgundy]];
    [Instabug setHeaderColor:[UIColor wh_beige]];
    [Instabug setButtonsFontColor:[UIColor wh_beige]];
    [Instabug setTextBackgroundColor:[UIColor wh_beige]];
    [Instabug setFloatingButtonForeColor:[UIColor wh_beige]];
    [Instabug setFloatingButtonBackColor:[UIColor wh_beige]];

    [Mixpanel sharedInstanceWithToken:kMixPanelToken];
    [BugSenseController sharedControllerWithBugSenseAPIKey:kBugSenseAPIKey];
#endif
    
    [RKEntityMapping setEntityIdentificationInferenceEnabled:NO];
    
    [RKObjectManager setSharedManager:[RKObjectManager managerWithBaseURL:[NSURL URLWithString:kBaseURLString]]];

    [[RKObjectManager sharedManager] setManagedObjectStore:[RKManagedObjectStore setupDefaultStore]];
    [[RKObjectManager sharedManager].HTTPClient setDefaultHeader:@"User-Locale"
                                                           value:[[NSLocale currentLocale] localeIdentifier]];
    
    [WHRestKitSetup setupWithObjectManager:[RKObjectManager sharedManager]];

    [PCDOperationTracker setSharedTracker:[PCDOperationTracker new]];
    [[PCDOperationTracker sharedTracker] setProgressBarColor:[UIColor wh_burgundy]];
    [PCDHUD setSharedHUDClass:[WHLoadingHUD class]];

    //We need to remap all photograph objects that belong to a cellar door.
    
    NSString * const kResetPhotographsKey = @"did_reset_cellar_photographs_1";
    if ([defaults boolForKey:kResetPhotographsKey] == NO) {
        NSArray * photographs = [WHPhotographMO MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"cellarDoors.@count > 0"]];
        [photographs enumerateObjectsUsingBlock:^(WHPhotographMO * photograph, NSUInteger idx, BOOL *stop) {
            for (WHWineryMO * winery in photograph.cellarDoors) {
                [winery setUpdatedAt:nil];
            }
        }];
        [WHPhotographMO MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"cellarDoors.@count > 0"]];
        [defaults setBool:YES forKey:kResetPhotographsKey];
    }
    
    //Update states.
    [[RKObjectManager sharedManager] getObjectsAtPathForRouteNamed:@"states" object:nil parameters:nil success:nil failure:nil];

    [WHApperance setupAppearance];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    ///
    
    WHRootViewController * rootViewController = [[WHRootViewController alloc] initWithNibName:nil bundle:nil];

    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [window setWindowLevel:UIWindowLevelNormal];
    [window setTintColor:[UIColor wh_burgundy]];
    [window setUserInteractionEnabled:YES];
    [window setRootViewController:rootViewController];
    [window makeKeyAndVisible];

    NSNumber * launchCount = [[NSUserDefaults standardUserDefaults] objectForKey:kWHAppLaunchCount];
    if(launchCount.integerValue <= 0){
        UIStoryboard * onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:[NSBundle mainBundle]];
        WHOnboardingViewController * onboardingVC = [onboardingStoryboard instantiateInitialViewController];
        [onboardingVC setDelegate:self];
        
        /*
         Due to number of libraries needing to be setup on 'didFinishLaunching'.
         This causes alerts to be displayed whilst user is viewing the onboarding screen.
         Therefor we are presenting onboarding in it's own window with the window lever above 'UIWindowLevelAlert'
         */
        
        UIWindow * onboardingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [onboardingWindow setWindowLevel:UIWindowLevelAlert+1.0];
        [onboardingWindow setRootViewController:onboardingVC];
        [onboardingWindow setBackgroundColor:[UIColor clearColor]];
        [onboardingWindow makeKeyAndVisible];
        [self setOnboardingWindow:onboardingWindow];

    } else if (launchCount.integerValue > 1) {
        if (self.splashWindow == nil) {

            WHSplashViewController * splashViewController = [WHSplashViewController new];

            UIWindow * splashWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [splashWindow setWindowLevel:WHLoadingHUDMaxWindowLevel+1.0];
            [splashWindow setRootViewController:splashViewController];
            [splashWindow setBackgroundColor:[UIColor clearColor]];
            [splashWindow setUserInteractionEnabled:NO];
            [splashWindow makeKeyAndVisible];
            [self setSplashWindow:splashWindow];
            
            [splashViewController startAnimationWithCompletionBlock:^{
                [window makeKeyAndVisible];
                [self setSplashWindow:nil];
            }];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:@(launchCount.integerValue+1) forKey:kWHAppLaunchCount];
    [[NSUserDefaults standardUserDefaults] synchronize];

    _window = window;
    
    [self setScheduledLocationManager:[[WHWineriesScheduledLocationManager alloc] init]];
    [self.scheduledLocationManager startUpdates];
    
    UILocalNotification * localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification != nil) {
        [self _handleLocalNotification:localNotification];
    }

    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self _handleLocalNotification:notification];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSettings setDefaultAppID:kFacebookAppId];
    [FBAppEvents activateApp];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:@(CACurrentMediaTime())
                                              forKey:kWHLastResignTime];
    if (self.splashWindow != nil) {
        [self setSplashWindow:nil];

        if ([application.keyWindow isEqual:self.window] == NO) {
            [self.window makeKeyAndVisible];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application { [AppTracker closeSession]; }
- (void)applicationWillTerminate:(UIApplication *)application { [MagicalRecord cleanUp]; }

#pragma mark

- (void)_handleLocalNotification:(UILocalNotification *)localNotification
{
    NSLog(@"%s - %@", __func__,localNotification);
    if (localNotification == nil) {
        return;
    }

    NSString * action = localNotification.userInfo[kWHNotificationAlertActionKey];
    if ([action isEqualToString:kWHNotificationAlertActionOpenWinery]) {
        NSNumber * wineryID = localNotification.userInfo[kWHNotificationWineryIDKey];
        NSLog(@"Open winery: %@",wineryID);
        if ([self.window.rootViewController isKindOfClass:[MMDrawerController class]]) {
            MMDrawerController * drawerController = (MMDrawerController *)self.window.rootViewController;
            if ([drawerController.centerViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController * centerTabBarController = (id)drawerController.centerViewController;
                if ([centerTabBarController.selectedViewController isKindOfClass:[UINavigationController class]]) {
                    UIStoryboard * wineriesStoryboard = [UIStoryboard storyboardWithName:@"Wineries" bundle:[NSBundle mainBundle]];
                    WHWineryViewController * wineryVC = [wineriesStoryboard instantiateViewControllerWithIdentifier:@"WHWineryViewController"];
                    [wineryVC setWineryId:wineryID];
                    [(UINavigationController *)centerTabBarController.selectedViewController pushViewController:wineryVC animated:YES];
                }
            }
        }
    }
}

#pragma mark
#pragma mark WHOnboardingViewControllerDelegate

- (void)onboardingViewController:(WHOnboardingViewController *)vc didTapStartButton:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.onboardingWindow setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.window makeKeyAndVisible];
        [self.onboardingWindow setHidden:YES];
        [self setOnboardingWindow:nil];
    }];
}

@end
