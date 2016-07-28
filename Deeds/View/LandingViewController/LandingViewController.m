//
//  LandingViewController.m
//  Deeds
//
//  Created by highjump on 15-4-7.
//
//

#import "LandingViewController.h"
#import "SWRevealViewController.h"

#import "MBProgressHUD.h"

#import "CommonUtils.h"
#import "UserData.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LandingViewController () {
    UIColor *mColorBlue;
    UIColor *mColorGreen;
    UIColor *mColorRed;
}

@property (weak, nonatomic) IBOutlet UIView *mViewBack;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@property (weak, nonatomic) IBOutlet UIButton *mButFacebook;
@property (weak, nonatomic) IBOutlet UIButton *mButSignin;
@property (weak, nonatomic) IBOutlet UIButton *mButSignup;

@property (weak, nonatomic) IBOutlet UIPageControl *mPageControl;

@end

@implementation LandingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // facebook button
    [self.mButFacebook.layer setMasksToBounds:YES];
    [self.mButFacebook.layer setCornerRadius:5];
    
    // signin button
    [self.mButSignin.layer setMasksToBounds:YES];
    [self.mButSignin.layer setCornerRadius:5];
    
    [self.mButSignin.layer setBorderWidth:1.0f];
    [self.mButSignin.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    // signup button
    [self.mButSignup.layer setMasksToBounds:YES];
    [self.mButSignup.layer setCornerRadius:5];
    
    [self.mButSignup.layer setBorderWidth:1.0f];
    [self.mButSignup.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    // init color
    mColorBlue = [UIColor colorWithRed:75/255.0 green:159/255.0 blue:216/255.0 alpha:0.95];
    mColorGreen = [UIColor colorWithRed:112/255.0 green:189/255.0 blue:129/255.0 alpha:0.95];
    mColorRed = [UIColor colorWithRed:238/255.0 green:108/255.0 blue:107/255.0 alpha:0.95];
    
    UserData *currentUser = [UserData currentUser];
    if (currentUser) {
        SWRevealViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController pushViewController:viewController animated:NO];
    }
    else {
        // facebook login
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_accessTokenChanged:)
                                                     name:FBSDKAccessTokenDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_currentProfileChanged:)
                                                     name:FBSDKProfileDidChangeNotification
                                                   object:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.mButFacebook setEnabled:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)_accessTokenChanged:(NSNotification *)notification
{
    FBSDKAccessToken *token = notification.userInfo[FBSDKAccessTokenChangeNewKey];
    
    if (token) {
        CommonUtils *utils = [CommonUtils sharedObject];
        utils.mFBCurToken = token;
    }
//    else {
//        [FBSDKAccessToken setCurrentAccessToken:nil];
//        [FBSDKProfile setCurrentProfile:nil];
//    }
}

- (void)_currentProfileChanged:(NSNotification *)notification
{
    FBSDKProfile *profile = notification.userInfo[FBSDKProfileChangeNewKey];
    if (profile) {
        CommonUtils *utils = [CommonUtils sharedObject];
        utils.mFBCurProfile = profile;
    }
}


- (IBAction)onButFacebook:(id)sender {
    
    [self.mButFacebook setEnabled:NO];
    
    NSArray *permissionsArray = @[@"user_about_me", @"email", @"user_location"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.mButFacebook setEnabled:YES];
            
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        }
        else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            
            [self setFBProfile];
        }
        else {
            NSLog(@"User logged in through Facebook!");
            
            [self setFBProfile];
        }
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)setFBProfile {
//    NSArray *permissionsArray = @[@"publish_actions"];
//    [PFFacebookUtils linkUserInBackground:[UserData currentUser]
//                   withPublishPermissions:permissionsArray
//                                    block:^(BOOL succeeded, NSError *error)
//     {
//         if (error) {
//             NSLog(@"%@", error);
//         }
//     }];

    CommonUtils *utils = [CommonUtils sharedObject];
    if (!utils.mFBCurProfile) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self gotoMain];
        return;
    }
    
    UserData *currentUser = [UserData currentUser];
    currentUser.firstname = utils.mFBCurProfile.firstName;
    currentUser.lastname = utils.mFBCurProfile.lastName;
    currentUser.fullname = [NSString stringWithFormat:@"%@ %@",
                            utils.mFBCurProfile.firstName,
                            utils.mFBCurProfile.lastName];
    
//    currentUser.username = utils.mFBCurProfile.userID;
    
    // photo info
    NSString *strPhoto = [utils.mFBCurProfile imagePathForPictureMode:FBSDKProfilePictureModeSquare size:utils.mszProfilePhoto];
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@", strPhoto]];
    NSData *data = [NSData dataWithContentsOfURL:pictureURL];
    PFFile *photoFile = [PFFile fileWithData:data];
    currentUser.photo = photoFile;

    [FBSDKAccessToken setCurrentAccessToken:utils.mFBCurToken];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (error) {
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:[error userInfo][@"error"]
                                                            delegate:nil cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [self.mButFacebook setEnabled:YES];
             
             return;
         }
         
         NSDictionary *userData = result;
         
         UserData *currentUser = [UserData currentUser];
         
         for(id key in userData)
         {
             NSLog(@"key=%@ value=%@", key, [userData objectForKey:key]);
         }
         
         if (userData[@"email"]) {
             currentUser.email = userData[@"email"];
             currentUser.username = userData[@"email"];
         }
         else {
             currentUser.username = utils.mFBCurProfile.userID;
         }
         
         // location and about
         if (userData[@"bio"]) {
             currentUser.about = userData[@"bio"];
         }
         if (userData[@"location"]) {
             currentUser.address = userData[@"location"][@"name"];
         }
         
         [currentUser saveInBackground];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self.mButFacebook setEnabled:YES];
         
         [self gotoMain];
     }];
}

- (void)gotoMain {
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (installation) {
        installation[@"user"] = [UserData currentUser];
        [installation saveInBackground];
    }
    [self performSegueWithIdentifier:@"Landing2Main" sender:nil];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.mScrollView.frame.size.width;
    NSInteger nPage = self.mScrollView.contentOffset.x / pageWidth;
    
    // Update the page control
    self.mPageControl.currentPage = nPage;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         switch (nPage) {
                             case 0:
                                 [self.mViewBack setBackgroundColor:mColorBlue];
                                 break;
                                 
                             case 1:
                                 [self.mViewBack setBackgroundColor:mColorGreen];
                                 break;
                                 
                             case 2:
                                 [self.mViewBack setBackgroundColor:mColorRed];
                                 break;
                                 
                             default:
                                 break;
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
