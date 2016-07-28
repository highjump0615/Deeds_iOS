//
//  DetailItemCell.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "DetailItemCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

#import "DetailViewController.h"

#import "CommonUtils.h"

#import "ItemData.h"
#import "UserData.h"
#import "NotificationData.h"

#import <Twitter/Twitter.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Accounts/Accounts.h>


@interface DetailItemCell() <FBSDKSharingDelegate> {
    ItemData *mItemData;
}


@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblAddress;
@property (weak, nonatomic) IBOutlet UILabel *mLblInfo;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;

@property (weak, nonatomic) IBOutlet UIButton *mButShare;
@property (weak, nonatomic) IBOutlet UIButton *mButFavourite;

@end

@implementation DetailItemCell

- (void)awakeFromNib {
    // Initialization code
    self.mfHeight = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(ItemData *)data forHeight:(BOOL)bForHeight {
    
    if (bForHeight) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat fLabelWidth = screenWidth - 16;
        
        self.mfHeight = 278 - 18 - 53;

        // title height
        CGSize constrainedSize = CGSizeMake(fLabelWidth, 9999);
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:15],
                                              NSFontAttributeName,
                                              nil];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:data.title
                                                                                   attributes:attributesDictionary];
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                     context:nil];
        self.mfHeight += requiredHeight.size.height	;
        
        // content height
        attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:11],
                                NSFontAttributeName,
                                nil];
        string = [[NSMutableAttributedString alloc] initWithString:data.desc
                                                        attributes:attributesDictionary];
        requiredHeight = [string boundingRectWithSize:constrainedSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                              context:nil];
        
        self.mfHeight += requiredHeight.size.height;
        self.mfHeight = ceil(self.mfHeight);
        
        return;
    }
    
    [self.mLblTitle setText:data.title];
    [self.mLblContent setText:data.desc];
    
    // address
    NSString *strAddress = data.address;
    if (!strAddress || [strAddress length] == 0) {
        strAddress = @"Unknown Location";
    }
    [self.mLblAddress setText:strAddress];
    
    // info
    NSMutableString *strInfoTotal = [NSMutableString stringWithString:@""];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    CGFloat fDist = [utils getDistanceFromPoint:data.location];
    
    if (fDist < 0) {
        [strInfoTotal appendString:@"Unknown"];
    }
    else {
        [strInfoTotal appendFormat:@"%.0fKM Away", fDist];
    }

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"MMMM dd yyyy"];
    NSString *strDate = [dateFormat stringFromDate:data.createdAt];
    
    [strInfoTotal appendFormat:@"   %@", strDate];
    
    [self.mLblInfo setText:strInfoTotal];
    
    // images
    PFFile *filePhoto = [data.images objectAtIndex:0];
    [self.mImgView1 sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    
    filePhoto = [data.images objectAtIndex:1];
    [self.mImgView2 sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    
    filePhoto = [data.images objectAtIndex:2];
    [self.mImgView3 sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    
    // favourite
    UserData *currentUser = [UserData currentUser];
    [self.mButFavourite setEnabled:![currentUser isItemFavourite:data]];
    
    
    mItemData = data;
}

- (void)dismissKeyboard {
    DetailViewController *viewController = (DetailViewController *)self.delegate;
    [viewController dismissKeyboard:nil];
}

- (IBAction)onButFavourite:(id)sender {
    
    [self dismissKeyboard];
    
    UserData *currentUser = [UserData currentUser];
    [currentUser.favourite addObject:mItemData];
    [currentUser saveInBackground];
    
    [currentUser.maryFavouriteItem addObject:mItemData];
    
    [self.mButFavourite setEnabled:NO];

    // if it is me, return
    if ([mItemData.user.objectId isEqualToString:currentUser.objectId]) {
        return;
    }

    // save to notification data
    NotificationData *notifyObj = [NotificationData object];
    notifyObj.item = mItemData;
    notifyObj.user = currentUser;
    notifyObj.username = [currentUser getUsernameToShow];
    notifyObj.targetuser = mItemData.user;
    notifyObj.type = NOTIFICATION_FAVOURITE;
    [notifyObj saveInBackground];
    
    //
    // like animation
    //
    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [pulseAnimation setDuration:0.2];
    [pulseAnimation setRepeatCount:3];
    
    // The built-in ease in/ ease out timing function is used to make the animation look smooth as the layer
    // animates between the two scaling transformations.
    [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    // Scale the layer to half the size
    CATransform3D transform = CATransform3DMakeScale(2.0, 2.0, 1.0);
    
    // Tell CA to interpolate to this transformation matrix
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
    
    // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
    [pulseAnimation setAutoreverses:YES];
    
    // Finally... add the explicit animation to the layer... the animation automatically starts.
    [self.mButFavourite.imageView.layer addAnimation:pulseAnimation forKey:@"BTSPulseAnimation"];

    //
    // send notification to favourite user
    //
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:mItemData.user];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%@ loves your post", [currentUser getUsernameToShow]], @"alert",
                          @"favourite", @"notifyType",
                          mItemData.objectId, @"notifyItem",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          nil];
    [push setData:data];
    
    [push sendPushInBackground];
}

- (IBAction)onButShare:(id)sender {
    
    [self dismissKeyboard];
    
    PFFile *filePhoto = [mItemData.images objectAtIndex:0];;
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = mItemData.title;
    content.contentDescription = mItemData.desc;
    content.imageURL = [NSURL URLWithString:filePhoto.url];
    content.contentURL = [NSURL URLWithString:filePhoto.url];
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    [shareDialog show];
    
    return;
//
//    
//    
//    
//    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
//    ACAccountType *facebookAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
//    
//    NSString *facebookAppID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
//    NSArray *permissions = @[@"publish_actions"];
//    NSDictionary *dict = @{ACFacebookAppIdKey : facebookAppID,
//                           ACFacebookPermissionsKey : permissions,
//                           ACFacebookAudienceKey:ACFacebookAudienceEveryone};
//    
//    [accountStore requestAccessToAccountsWithType:facebookAccountType options:dict completion:^(BOOL granted, NSError *error) {
//        if (!granted) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
//                                                           message:@"Please sign in to Facebook on Phone Settings"
//                                                          delegate:nil
//                                                 cancelButtonTitle:@"OK"
//                                                 otherButtonTitles:nil];
//            
//            [alert show];
//        }
//        else {
//            
//            NSArray *accounts = [accountStore accountsWithAccountType:facebookAccountType];
//            ACAccount *account = [accounts lastObject];
//            
//            ACAccountCredential *fbCredential = [account credential];
//            NSLog(@"username: %@", account.username);
//            NSLog(@"userfullname: %@", account.userFullName);
//            NSLog(@"facebook account =%@",[account valueForKeyPath:@"properties.uid"]);
//            
//            NSString *accessToken = [fbCredential oauthToken];
//            
//            SLComposeViewController *facebookSheet = [SLComposeViewController
//                                                      composeViewControllerForServiceType:
//                                                      SLServiceTypeFacebook];
//            
//            
//            FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
////
////            [FBSDKAccessToken alloc] initWithTokenString:<#(NSString *)#> permissions:<#(NSArray *)#> declinedPermissions:<#(NSArray *)#> appID:<#(NSString *)#> userID:<#(NSString *)#> expirationDate:<#(NSDate *)#> refreshDate:<#(NSDate *)#>
////            
////            if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
////                
////                FBSDKSharePhoto *photo1 = [[FBSDKSharePhoto alloc] init];
////                photo1.image = self.mImgView1.image;
////                photo1.userGenerated = YES;
////                FBSDKSharePhoto *photo2 = [[FBSDKSharePhoto alloc] init];
////                photo2.image = self.mImgView2.image;
////                photo2.userGenerated = YES;
////                FBSDKSharePhoto *photo3 = [[FBSDKSharePhoto alloc] init];
////                photo3.image = self.mImgView3.image;
////                photo3.userGenerated = YES;
////                
////                FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
////                content.photos = @[photo1, photo2, photo3];
////            
////                [FBSDKShareDialog showFromViewController:viewController
////                                             withContent:content
////                                                delegate:nil];
////            }
//        }
//    }];
//    
//    return;
//    
//    
//    
//    
////    [self.mButShare setEnabled:NO];
//    
//    UIViewController *viewController = (UIViewController *)self.delegate;
//    
//    NSArray *permissionsArray = @[@"publish_actions"];
//    [PFFacebookUtils linkUserInBackground:[UserData currentUser]
//                   withPublishPermissions:permissionsArray
//                                    block:^(BOOL succeeded, NSError *error)
//     {
//         [MBProgressHUD hideHUDForView:viewController.view animated:YES];
//         [self.mButShare setEnabled:YES];
//         
//         if (error) {
//             NSLog(@"%@", error);
//             return;
//         }
//    
////    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
////        NSLog(@"available");
////    }
////    
////         FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
////    if (!token || ![token hasGranted:@"publish_actions"]) {
////        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
////        [login logInWithPublishPermissions:@[@"publish_actions"]
////                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
////        {
////            if (error) {
////                NSLog(@"%@", error);
////                return;
////            }
////            
////            if (result.isCancelled) {
////                NSLog(@"cancelled");
////                return;
////            }
//    
//            FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
//            
//            if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//                
//                FBSDKSharePhoto *photo1 = [[FBSDKSharePhoto alloc] init];
//                photo1.image = self.mImgView1.image;
//                photo1.userGenerated = YES;
//                FBSDKSharePhoto *photo2 = [[FBSDKSharePhoto alloc] init];
//                photo2.image = self.mImgView2.image;
//                photo2.userGenerated = YES;
//                FBSDKSharePhoto *photo3 = [[FBSDKSharePhoto alloc] init];
//                photo3.image = self.mImgView3.image;
//                photo3.userGenerated = YES;
//                
//                FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
//                content.photos = @[photo1, photo2, photo3];
//                
//                [FBSDKShareDialog showFromViewController:viewController
//                                             withContent:content
//                                                delegate:nil];
//            }
//
//            
////        }];
////    }
//    
//    
////         SLComposeViewController *facebookSheet = [SLComposeViewController
////                                                   composeViewControllerForServiceType:
////                                                   SLServiceTypeFacebook];
////
////         // Sets the completion handler.  Note that we don't know which thread the
////         // block will be called on, so we need to ensure that any required UI
////         // updates occur on the main queue
////         facebookSheet.completionHandler = ^(SLComposeViewControllerResult result) {
////             switch(result) {
////                     //  This means the user cancelled without sending the Tweet
////                 case SLComposeViewControllerResultCancelled:
////                     NSLog(@"SLComposeViewControllerResultCancelled");
////                     break;
////                     //  This means the user hit 'Send'
////                 case SLComposeViewControllerResultDone: {
////                     NSLog(@"SLComposeViewControllerResultDone");
////                     //                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Success"
////                     //                                                                message:@"Successfully posted to Facebook"
////                     //                                                               delegate:nil
////                     //                                                      cancelButtonTitle:@"OK"
////                     //                                                      otherButtonTitles:nil];
////                     //                [alert show];
////                     break;
////                 }
////             }
////         };
////         
////         //  Set the initial body of the Tweet
////         [facebookSheet setInitialText:[NSString stringWithFormat:@"%@\n%@",
////                                        mItemData.title,
////                                        mItemData.desc]];
////         
////         //  Adds an image to the Tweet.  For demo purposes, assume we have an
////         //  image named 'larry.png' that we wish to attach
////         [facebookSheet addImage:self.mImgView1.image];
////         [facebookSheet addImage:self.mImgView2.image];
////         [facebookSheet addImage:self.mImgView3.image];
////         
////         //  Presents the Tweet Sheet to the user
////         [self.delegate presentViewController:facebookSheet animated:NO completion:^{
////             NSLog(@"Facebook posting has done.");
////         }];
//    
//     }];
//
//    
//    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
}

- (IBAction)onButReport:(id)sender {
    
    [self dismissKeyboard];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Do you want to report this item?"
                                                   message:@""
                                                  delegate:self
                                         cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes",nil];
    [alert show];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblTitle.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblTitle.frame);
    self.mLblInfo.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblInfo.frame);
    self.mLblContent.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblContent.frame);
    
    [self.mImgView1.layer setMasksToBounds:YES];
    [self.mImgView1.layer setCornerRadius:3];
    
    [self.mImgView2.layer setMasksToBounds:YES];
    [self.mImgView2.layer setCornerRadius:3];
    
    [self.mImgView3.layer setMasksToBounds:YES];
    [self.mImgView3.layer setCornerRadius:3];
    
    // shadow on view
    CGRect rtShadow = self.bounds;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.3f;
    self.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [mItemData incrementKey:@"reportcount"];
        [mItemData saveInBackground];
    }
}

#pragma mark - FBSDKSharingDelegate

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"completed share:%@", results);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"sharing error:%@", error);
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sharing, please try again later.";
    NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"share cancelled");
}


@end
