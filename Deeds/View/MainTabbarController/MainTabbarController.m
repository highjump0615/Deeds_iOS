//
//  MainTabbarController.m
//  Deeds
//
//  Created by highjump on 15-4-10.
//
//

#import "MainTabbarController.h"
#import "SWRevealViewController.h"
#import "MainViewController.h"
#import "FavouriteViewController.h"

#import "CommonUtils.h"

#import "UserData.h"
#import "GeneralData.h"
#import "CategoryData.h"

#import <CoreLocation/CoreLocation.h>

@interface MainTabbarController () <UITabBarControllerDelegate, CLLocationManagerDelegate> {
    CLLocationManager *mLocationManager;
}

@end

@implementation MainTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDelegate:self];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    utils.mTabbarController = self;
    
    //
    // init location object
    //
    mLocationManager = [[CLLocationManager alloc] init];
    mLocationManager.delegate = self;
    mLocationManager.distanceFilter = kCLLocationAccuracyKilometer;
    
    if ([mLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [mLocationManager requestWhenInUseAuthorization];
    }
    
    mLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
//    [mLocationManager startMonitoringSignificantLocationChanges];
    [mLocationManager startUpdatingLocation];
    
    UserData *currentUser = [UserData currentUser];
    [currentUser getFavouriteItem:^{
        [self reloadTable];
    }];
    
    PFQuery *query = [GeneralData query];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            GeneralData *data = (GeneralData *)object;
            utils.mnItemcount = [data.itemcount integerValue];
            utils.mnItemdone = [data.itemdone integerValue];
        }
    }];
    
    // get category data
    query = [CategoryData query];
    [query orderByAscending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [utils.maryCategory removeAllObjects];
            
            for (CategoryData *obj in objects) {
                [utils.maryCategory addObject:obj];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)reloadTable {
    UIViewController *viewController = self.selectedViewController;
    
    if ([viewController isKindOfClass:[MainViewController class]]) {
        MainViewController *mvc = (MainViewController *)viewController;
        [mvc reloadTable];
    }
    else if ([viewController isKindOfClass:[FavouriteViewController class]]) {
        FavouriteViewController *fvc = (FavouriteViewController *)viewController;
        [fvc onButSearch:nil];
    }
}

- (void)revealLeftSidebar:(id)sender {
    [self.revealViewController revealToggle:sender];
}

- (void)revealRightSidebar:(id)sender {
    [self.revealViewController rightRevealToggle:sender];
}

- (void)closeSidebar {
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
}


#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    // close side bar
    [self closeSidebar];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (status == kCLAuthorizationStatusAuthorized ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways)
    {
        //        NSLog(@"kCLAuthorizationStatusAuthorized");
        // Re-enable the post button if it was disabled before.
        //			self.navigationItem.rightBarButtonItem.enabled = YES;
//        [mLocationManager startMonitoringSignificantLocationChanges];
        [mLocationManager startUpdatingLocation];
    }
    else if (status == kCLAuthorizationStatusDenied)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"DeeD can’t access your current location.\n\nTo see the places at your current location, turn on access for DeeD to your location in the Settings app under Location Services."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else if (status == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"kCLAuthorizationStatusNotDetermined");
    }
    else if (status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"kCLAuthorizationStatusRestricted");
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    //    UIAlertView *errorAlert = [[UIAlertView alloc]
    //                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (newLocation) {
        utils.mLocationCurrent = newLocation;
        
        UserData *currentUser = [UserData currentUser];
        currentUser.location = [PFGeoPoint geoPointWithLatitude:utils.mLocationCurrent.coordinate.latitude
                                                      longitude:utils.mLocationCurrent.coordinate.longitude];
        [currentUser saveInBackground];
    }
}


@end
