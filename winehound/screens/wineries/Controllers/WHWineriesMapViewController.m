//
//  WHWineriesMapViewController.m
//  WineHound
//
//  Created by Mark Turner on 27/11/2013.
//  Copyright (c) 2013 Papercloud. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <PCDefaults/PCDefaults.h>
#import <MagicalRecord/NSManagedObject+MagicalFinders.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MapKit/MapKit.h>

#import "WHWineriesMapViewController.h"
#import "WHWineryViewController.h"
#import "WHMapCalloutView.h"
#import "WHLoadingHUD.h"

#import "WHWineryMO+Mapping.h"
#import "WHWineryMO+Additions.h"
#import "WHWineryMO+Mapping.h"
#import "WHRegionMO+Additions.h"

#import "WHFavouriteMO+Additions.h"
#import "WHFavouriteAlertView.h"
#import "WHFavouriteManager.h"
#import "WHAlertView.h"
#import "WHMapIconManager.h"

#import "UIFont+Edmondsans.h"
#import "UIActivityIndicatorView+PCDLoading.h"
#import "NSString+ReformatTel.h"
#import "PCDCollectionMergeManagerFixStart.h"

#import <PCDMapManager.h>
#import <PCDMapManagerDataSource.h>

#import <RestKit/CoreData/RKFetchRequestManagedObjectCache.h>

@interface WHWineriesMapViewController () <GMSMapViewDelegate,WHMapCalloutViewDelegate,WHFavouriteAlertViewDelegate,PCDMapManagerDataSource>
{
    __weak IBOutlet NSLayoutConstraint *_activityViewTopLayoutConstraint;
    
}
@property (weak) WHMapCalloutView * calloutView;
@property (nonatomic) BOOL zoomToBounds;
@property (nonatomic) WHMapIconManager * mapIconManager;
@property (nonatomic, strong) PCDMapManager *mapManager;
@end

@implementation WHWineriesMapViewController

UIImage * wineryMarkerImage(WHWineryMO * winery) {
    if (winery.type.intValue == WHWineryTypeBrewery) {
        return [UIImage imageNamed:@"map_brewery_pin"];
    }
    if (winery.type.intValue == WHWineryTypeCidery) {
        return [UIImage imageNamed:@"map_cidery_pin"];
    }
    return [UIImage imageNamed:WHWineryMarkerImageName[winery.tierValue]];
}

- (WHMapIconManager *)mapIconManager
{
    if (_mapIconManager == nil) {
        WHMapIconManager * mapIconManager = [WHMapIconManager new];
        _mapIconManager = mapIconManager;
    }
    return _mapIconManager;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setFetchWineryTypes:WHWineryMapTypeWinery];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Map"];
    
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    [self.mapView setMyLocationEnabled:YES];
    [self.mapView setDelegate:self];
    
    [self.mapView.settings setMyLocationButton:YES];
    [self.mapView.settings setCompassButton:YES];

    [self.activityIndicatorView setHidesWhenStopped:YES];
    
    //
    
    if (self.regionId != nil) {
        [self setZoomToBounds:YES];
    } else {
        [self setZoomToBounds:NO];
    }
    
    if (self.regionId != nil) {
        WHRegionMO * region = [WHRegionMO MR_findFirstByAttribute:@"regionId" withValue:self.regionId];
        CGFloat mapZoom = 8.0;
        if (region.zoomLevel != nil) {
            mapZoom = region.zoomLevel.floatValue;
        }
        [self.mapView setCamera:[GMSCameraPosition cameraWithTarget:region.location.coordinate
                                                               zoom:mapZoom]];
    } else {
        if (self.mapView.myLocation != nil) {
            [self.mapView setCamera:[GMSCameraPosition cameraWithTarget:self.mapView.myLocation.coordinate zoom:5.0]];
        } else {
            [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:-37.8131869 longitude:144.9629796 zoom:5.0]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [UIActivityIndicatorView setCurrentActivityIndicatorView:self.activityIndicatorView];
    
    //Update view if winery object has changed...
    [_calloutView setWinery:_calloutView.winery];
    
    __weak typeof (self) weakSelf = self;
    
    PCDCollectionMergeManager * collectionManager = [PCDCollectionMergeManagerFixStart collectionManagerWithClass:[WHWineryMO class]];
    [collectionManager setHudClass:[UIActivityIndicatorView class]];
    [collectionManager setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"tier" ascending:YES]]];

    /*
     Ideally we would like to sort by distance & limit the fetch results to only fetch x amount nearest the center of the map.
     However using collection managers comparator is pointless, as this is performed after fetch request has been performed.
     
     [collectionManager setComparator:^NSComparisonResult(id, id) {
     
     }];
     */
    
    
    PCDMapManager * mapManager = [[PCDMapManager alloc] initWithMapView:self.mapView
                                                      collectionManager:(PCDCollectionManager *)collectionManager];
    [mapManager setDatasource:self];
    [mapManager setFiltersBlock:^{
        BOOL fetchwineries  = weakSelf.fetchWineryTypes & WHWineryMapTypeWinery  ? YES : NO;
        BOOL fetchbreweries = weakSelf.fetchWineryTypes & WHWineryMapTypeBrewery ? YES : NO;
        BOOL fetchCideries  = weakSelf.fetchWineryTypes & WHWineryMapTypeCidery  ? YES : NO;
        
        NSMutableArray * predicateArray = @[].mutableCopy;
        NSMutableArray * parameterArray = @[].mutableCopy;
        if (fetchwineries) {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"type == 1 OR type == 0"]];
            [parameterArray addObject:@"Winery"];
        }
        if (fetchbreweries) {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"type == 2"]];
            [parameterArray addObject:@"Brewery"];
        }
        if (fetchCideries) {
            [predicateArray addObject:[NSPredicate predicateWithFormat:@"type == 3"]];
            [parameterArray addObject:@"Cidery"];
        }
        
        PCDCollectionFilter * wineriesFilter = [PCDCollectionFilter new];
        [wineriesFilter setParameters:@{@"type":parameterArray}];
        [wineriesFilter setPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:predicateArray]];
        
        NSArray * filtersArray = @[wineriesFilter];
        if (weakSelf.regionId != nil) {
            PCDCollectionFilter * regionFilter = [PCDCollectionFilter new];
            [regionFilter setPredicate:[NSPredicate predicateWithFormat:@"ANY regions.regionId == %@",weakSelf.regionId]];
            [regionFilter setParameters:@{@"region":weakSelf.regionId.stringValue}];
            filtersArray = [filtersArray arrayByAddingObject:regionFilter];
        }
        
        return filtersArray;
    }];
    
    [self setMapManager:mapManager];
    
    BOOL fetchbreweries = weakSelf.fetchWineryTypes & WHWineryMapTypeBrewery ? YES : NO;
    BOOL fetchCideries  = weakSelf.fetchWineryTypes & WHWineryMapTypeCidery  ? YES : NO;
    if (fetchbreweries || fetchCideries) {
        [collectionManager.fetchedResultsController.fetchRequest setIncludesSubentities:YES];
        [(RKFetchRequestManagedObjectCache *)collectionManager.managedObjectCache setExcludeSubentities:NO];
    }
    
    [self.mapManager initialLoad];
    
    if (self.displayCalloutForWineryId != nil) {
        [self _displayCalloutForWineryId:self.displayCalloutForWineryId];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [WHLoadingHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIActivityIndicatorView setCurrentActivityIndicatorView:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self setMapManager:nil];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];

    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentEdgeInsets, UIEdgeInsetsZero)) {
        [_activityViewTopLayoutConstraint setConstant:self.contentEdgeInsets.top];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentEdgeInsets, UIEdgeInsetsZero)) {
        [self.mapView setPadding:self.contentEdgeInsets];
    }
}

- (void)dealloc
{
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
}

#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"DisplayWinery"]) {
        WHWineryMO * winery = (WHWineryMO *)sender;
        WHWineryViewController * wineryVC = (WHWineryViewController*)segue.destinationViewController;
        [wineryVC setWineryId:winery.wineryId];
    }
}

#pragma mark
#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"%s", __func__);
    /*
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    [self.mapView setCamera:[GMSCameraPosition cameraWithTarget:location.coordinate zoom:14]];
     */

    if (_calloutView != nil) {
        [_calloutView setDistance:[self distanceStringForMapCalloutView:_calloutView]];
    }
}

#pragma mark 
#pragma mark WHMapCalloutViewDelegate

- (void)mapCalloutView:(WHMapCalloutView *)view didTapFavouriteButton:(UIButton *)button
{
    NSLog(@"%s", __func__);

    WHFavouriteMO * favourite = [WHFavouriteMO favouriteWithEntityName:[WHWineryMO entityName] identifier:view.winery.wineryId];
    if (favourite == nil) {
        AFNetworkReachabilityStatus reachability = [[[RKObjectManager sharedManager] HTTPClient] networkReachabilityStatus];
        if (reachability == AFNetworkReachabilityStatusReachableViaWWAN || reachability == AFNetworkReachabilityStatusReachableViaWiFi) {
            NSArray * views = [[NSBundle mainBundle] loadNibNamed:@"WHFavouriteAlertView" owner:nil options:nil];
            WHFavouriteAlertView * favouriteAlertView = [views firstObject];
            [favouriteAlertView setDelegate:(id)self];
            
            if ([WHFavouriteManager email] == nil) {
                [favouriteAlertView displayEmailEntry];
            }
            
            [WHAlertView presentView:favouriteAlertView animated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"kFavouriteNoInternetAlertTitle", nil)
                                        message:NSLocalizedString(@"kFavouriteNoInternetAlertMessage", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
        }
    } else {
        BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName] identifier:[view.winery wineryId]];
        [button setSelected:didFavourite];
    }
}

- (void)mapCalloutView:(WHMapCalloutView *)view didTapTelephoneButton:(UIButton *)button
{
    UIApplication * application = [UIApplication sharedApplication];
    NSURL * telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",view.winery.phoneNumber.escaped]];
    if ([application canOpenURL:telURL] == YES) {
        [application openURL:telURL];
    }
}

- (void)mapCalloutView:(WHMapCalloutView *)view didTapDrivingDirectionsButton:(UIButton *)button
{
    WHWineryMO * winery = view.winery;
    if (winery.location != nil) {
        CLLocation * wineryLocation = [winery location];
        NSString * destination = [NSString stringWithFormat:@"%f,%f",wineryLocation.coordinate.latitude,wineryLocation.coordinate.longitude];
        
        NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%@&directionsmode=driving",destination]];
        UIApplication * application = [UIApplication sharedApplication];
        
        if ([application canOpenURL:url]) {
            [application openURL:url];
        } else if ([MKMapItem respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
            CLLocationCoordinate2D destination = wineryLocation.coordinate;
            
            MKMapItem * destinationMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil]];
            [destinationMapItem setName:winery.name];
            
            [MKMapItem openMapsWithItems:@[[MKMapItem mapItemForCurrentLocation],destinationMapItem]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                           MKLaunchOptionsMapTypeKey       :@(MKMapTypeStandard),
                                           MKLaunchOptionsShowsTrafficKey  :@YES}];
        } else {
            NSLog(@"Cannot provide directions");
        }
    }
}

- (void)mapCalloutViewDidTapView:(WHMapCalloutView *)view
{
    NSLog(@"%s", __func__);
    
    WHWineryMO * wineryObject = [view winery];
    if (wineryObject.type.intValue == WHWineryTypeWinery || wineryObject.type.intValue == 0) {
        [self performSegueWithIdentifier:@"DisplayWinery" sender:wineryObject];
    }
}

- (NSString *)distanceStringForMapCalloutView:(WHMapCalloutView *)view
{
    WHWineryMO * wineryObject = view.winery;
    if (wineryObject != nil) {
        CLLocationDistance distance = [self.mapView.myLocation distanceFromLocation:wineryObject.location];
        CGFloat kilometer = (distance/1000.0);
        if (kilometer > 1.0) {
            return [NSString stringWithFormat:@"%.0f km",kilometer];
        } else {
            return [NSString stringWithFormat:@"%.2f km",kilometer];
        }
    }
    return nil;
}

#pragma mark WHFavouriteAlertViewDelegate

- (void)favouriteAlertView:(WHFavouriteAlertView *)view didTapOptOutButton:(UIButton *)button
{
    BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName]
                                                identifier:self.calloutView.winery.wineryId];
    [self.calloutView.favouriteButton setSelected:didFavourite];

    [[WHAlertView currentAlertView] dismiss];
    
    if (self.calloutView.winery.wineryId != nil) {
        [[Mixpanel sharedInstance] track:@"Favourited Winery" properties:@{@"winery_id": self.calloutView.winery.wineryId,
                                                                           @"opted_out": @(YES)}];
    }
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
        
        NSNumber * wineryId = self.calloutView.winery.wineryId;
        
        if (wineryId != nil) {
            [PCDHUD show];
            
            __weak typeof(self) blockSelf = self;
            [WHFavouriteManager favouriteWineryId:_calloutView.winery.wineryId
                                        withEmail:email
                                         callback:^(BOOL success, NSError *error) {
                                             if (success ) {
                                                 [WHLoadingHUD dismiss];
                                                 
                                                 BOOL didFavourite = [WHFavouriteMO favouriteEntityName:[WHWineryMO entityName] identifier:wineryId];
                                                 [blockSelf.calloutView.favouriteButton setSelected:didFavourite];
                                                 
                                                 //TODO - Implement shared WHAlertView getter
                                                 WHAlertView * alertView = (WHAlertView*)view.superview;
                                                 [alertView dismiss];
                                                 
                                                 if (wineryId != nil) {
                                                     [[Mixpanel sharedInstance] track:@"Favourited Winery" properties:@{@"winery_id": wineryId}];
                                                 }
                                                 
                                             } else {
                                                 NSLog(@"Failed to add to mailing list: %@",error);
                                                 [PCDHUD showError:error];
                                             }
                                         }];

        }
    }
}

#pragma mark
#pragma mark GMSMapViewDelegate

/**
 * Called before the camera on the map changes, either due to a gesture,
 * animation (e.g., by a user tapping on the "My Location" button) or by being
 * updated explicitly via the camera or a zero-length animation on layer.
 *
 * @param gesture If YES, this is occuring due to a user gesture.
 */
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    NSLog(@"%s", __func__);
}

/**
 * Called repeatedly during any animations or gestures on the map (or once, if
 * the camera is explicitly set). This may not be called for all intermediate
 * camera positions. It is always called for the final position of an animation
 * or gesture.
 */
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    [self replaceCalloutViewForCoordinates:[mapView.selectedMarker position] inMap:mapView];
}

/**
 * Called when the map becomes idle, after any outstanding gestures or
 * animations have completed (or after the camera has been explicitly set).
 */
//- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
//{
//	[self reloadThings];
//}

/**
 * Called after a tap gesture at a particular coordinate, but only if a marker
 * was not tapped.  This is called before deselecting any currently selected
 * marker (the implicit action for tapping on the map).
 */
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"%s", __func__);
    [_calloutView removeFromSuperview];
}

/**
 * Called after a marker has been tapped.
 *
 * @param mapView The map view that was pressed.
 * @param marker The marker that was pressed.
 * @return YES if this delegate handled the tap event, which prevents the map
 *         from performing its default selection behavior, and NO if the map
 *         should continue with its default selection behavior.
 */
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"%s", __func__);
    
    NSNumber * wineryId = marker.userData;
    [self _displayCalloutForWineryId:wineryId];
    
    return YES;
}

#pragma mark 
#pragma mark PCDMapManagerDataSource

- (GMSMarker *)mapView:(GMSMapView *)mapView markerForEntityObject:(id)object
{
    WHWineryMO *wineryObject = (WHWineryMO *)object;
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(wineryObject.latitude.doubleValue,wineryObject.longitude.doubleValue);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    [marker setTitle:wineryObject.name]	;
    [marker setUserData:wineryObject.wineryId];
    [marker setAppearAnimation:kGMSMarkerAnimationNone];
    
    __weak typeof (self) weakSelf = self;
    
    if (wineryObject.type.intValue == WHWineryTypeWinery || wineryObject.type.intValue == 0) {
        if (wineryObject.tierValue <= WHWineryTierGold && wineryObject.logoURL.length > 0) {
            [self.mapIconManager logoOperationWithWinery:wineryObject
                                            withCallback:^(id wineryIcon) {
                                                [marker setIcon:wineryIcon ?: wineryMarkerImage(wineryObject)];
                                                [marker setMap:weakSelf.mapView];
                                            }];
        } else {
            [marker setIcon:wineryMarkerImage(wineryObject)];
            [marker setMap:mapView];
        }
    } else {
        //Beer or Cidery
        [marker setIcon:wineryMarkerImage(wineryObject)];
        [marker setMap:mapView];
    }
    return marker;
}

#pragma mark
#pragma mark -

- (void)_displayCalloutForWineryId:(NSNumber *)wineryId
{
    WHWineryMO * wineryObject = [WHWineryMO MR_findFirstByAttribute:@"wineryId" withValue:wineryId];

    [_calloutView removeFromSuperview];

    if (wineryObject != nil) {
        CLLocationCoordinate2D position = wineryObject.location.coordinate;
        
        WHMapCalloutView * calloutView = [WHMapCalloutView new];
        [calloutView setMarkerPosition:position];
        [calloutView setDelegate:self];
        [calloutView setWinery:wineryObject];
        [self.mapView addSubview:calloutView];
        _calloutView = calloutView;
        
        [self replaceCalloutViewForCoordinates:position inMap:self.mapView];
        [self.mapView animateToLocation:position];
    }
}

- (void)replaceCalloutViewForCoordinates:(CLLocationCoordinate2D)coordinate inMap:(GMSMapView *)mapView
{
    CLLocationCoordinate2D anchor = [_calloutView markerPosition];
    
    CGFloat heightOfMarker = .0f;
    
    if (_calloutView.winery.type.intValue == WHWineryTypeWinery ||
        _calloutView.winery.type.intValue == 0) {
        
        switch (_calloutView.winery.tierValue) {
                case WHWineryTierGoldPlus:
                case WHWineryTierGold:
                heightOfMarker =  65.0;
                break;
                case WHWineryTierSilver:
                heightOfMarker =  50.0;
                break;
                case WHWineryTierBronze:
                heightOfMarker =  40.0;
                break;
                case WHWineryTierBasic:
                heightOfMarker =  23.0;
            default:
                break;
        }
    } else {
        heightOfMarker =  20.0;
    }
    
    CGPoint pt = [mapView.projection pointForCoordinate:anchor];
    pt.x -= _calloutView.requiredSize.width * 0.5;
    pt.y -= _calloutView.requiredSize.height + heightOfMarker;
    _calloutView.frame = (CGRect) { .origin = pt, .size = _calloutView.frame.size };
}

- (void)setMapInteractionEnabled:(BOOL)enabled
{
    [self.mapView.settings setAllGesturesEnabled:enabled];
    [self.mapView.settings setMyLocationButton:enabled];
}

@end
