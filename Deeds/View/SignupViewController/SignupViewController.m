//
//  SignupViewController.m
//  Deeds
//
//  Created by highjump on 15-4-10.
//
//

#import "SignupViewController.h"
#import "PlaceholderTextView.h"

#import "MBProgressHUD.h"
#import "CommonUtils.h"
#import "UIImageView+WebCache.h"

#import "UserData.h"
#import "ItemData.h"
#import "NotificationData.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>



@interface SignupViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSInteger mnPage;
    
    UIView *mTxtCurrent;
    BOOL mbIsViewPushed;
    int mnPushedHeight;
    CGSize mszKeyboard;
    
    UIImagePickerController *mImagePicker;
    UIImage *mImgPhoto;
    
    NSString *mstrNameOld;
    NSInteger mnAboutMaxLen;
}

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

// first page
@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UITextField *mTxtEmail;
@property (weak, nonatomic) IBOutlet UITextField *mTxtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *mTxtLastName;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPhone;
@property (weak, nonatomic) IBOutlet UITextField *mTxtAddress;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPwd;
@property (weak, nonatomic) IBOutlet UIView *mViewPwdLine;
@property (weak, nonatomic) IBOutlet UITextField *mTxtRepeatPwd;
@property (weak, nonatomic) IBOutlet UIView *mViewRepeatPwdLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstHeaderEmail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstEmailFirst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstFirstLast;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstLastPhone;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstPhoneAddress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstAddressPwd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstPwdRepeat;

@property (weak, nonatomic) IBOutlet UISwitch *mSwitchAgree;
@property (weak, nonatomic) IBOutlet UILabel *mLblAgree;
@property (weak, nonatomic) IBOutlet UIButton *mButTerm;

@property (weak, nonatomic) IBOutlet UIButton *mButLogout;

// second page
@property (weak, nonatomic) IBOutlet UIView *mViewPhotoBack;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet UIView *mViewButton;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *mTxtAbout;
@property (weak, nonatomic) IBOutlet UILabel *mLblLeftLen;

@property (weak, nonatomic) IBOutlet UIButton *mButNext;
@property (weak, nonatomic) IBOutlet UIPageControl *mPageControl;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // first page
    // regulate space
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat fConstraint;
    CGFloat fOriginalHeight = self.mCstHeaderEmail.constant
                            + self.mCstEmailFirst.constant
                            + self.mCstFirstLast.constant
                            + self.mCstLastPhone.constant
                            + self.mCstPhoneAddress.constant
                            + self.mCstAddressPwd.constant
                            + self.mCstPwdRepeat.constant;
    CGFloat fDiff = 568 - fOriginalHeight;
    screenHeight -= fDiff;
    
    fConstraint = self.mCstHeaderEmail.constant / fOriginalHeight * screenHeight;
    [self.mCstHeaderEmail setConstant:fConstraint];
    fConstraint = self.mCstEmailFirst.constant / fOriginalHeight * screenHeight;
    [self.mCstEmailFirst setConstant:fConstraint];
    fConstraint = self.mCstFirstLast.constant / fOriginalHeight * screenHeight;
    [self.mCstFirstLast setConstant:fConstraint];
    fConstraint = self.mCstLastPhone.constant / fOriginalHeight * screenHeight;
    [self.mCstLastPhone setConstant:fConstraint];
    fConstraint = self.mCstPhoneAddress.constant / fOriginalHeight * screenHeight;
    [self.mCstPhoneAddress setConstant:fConstraint];
    fConstraint = self.mCstAddressPwd.constant / fOriginalHeight * screenHeight;
    [self.mCstAddressPwd setConstant:fConstraint];
    fConstraint = self.mCstPwdRepeat.constant / fOriginalHeight * screenHeight;
    [self.mCstPwdRepeat setConstant:fConstraint];
    
    // second page
    [self.mViewButton.layer setMasksToBounds:YES];
    [self.mViewButton.layer setCornerRadius:3];
    
    [self.mTxtAbout setPlaceholder:@"Tell us something about you..."];
    
    [self.mButNext.layer setMasksToBounds:YES];
    [self.mButNext.layer setCornerRadius:3];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    // keybaord
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    mnAboutMaxLen = 135;
    
    if (self.mUser) {
        [self.mSwitchAgree setHidden:YES];
        [self.mLblAgree setHidden:YES];
        [self.mButTerm setHidden:YES];
        [self.mButLogout setHidden:NO];
        
        [self.mTxtPwd setHidden:YES];
        [self.mViewPwdLine setHidden:YES];
        [self.mTxtRepeatPwd setHidden:YES];
        [self.mViewRepeatPwdLine setHidden:YES];
        
        UserData *currentUser = [UserData currentUser];
        [self.mTxtEmail setText:currentUser.email];
        [self.mTxtFirstName setText:currentUser.firstname];
        [self.mTxtLastName setText:currentUser.lastname];
        [self.mTxtPhone setText:currentUser.phone];
        [self.mTxtAddress setText:currentUser.address];
        [self.mTxtAbout setText:currentUser.about];
        
        [self.mLblLeftLen setText:[NSString stringWithFormat:@"%lu", mnAboutMaxLen - [currentUser.about length]]];
        
        // show photo
        PFFile *filePhoto = currentUser.photo;
        [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                              placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        
        [self.mLblTitle setText:@"Please hit next step after making changes"];
    }
    else {
        [self.mLblTitle setText:@"Please fill out to sign up"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {

    double dRadius = self.mViewPhotoBack.frame.size.height / 2;
    [self.mViewPhotoBack.layer setMasksToBounds:YES];
    [self.mViewPhotoBack.layer setCornerRadius:dRadius];
    
    dRadius = self.mImgViewPhoto.frame.size.height / 2;
    [self.mImgViewPhoto.layer setMasksToBounds:YES];
    [self.mImgViewPhoto.layer setCornerRadius:dRadius];

}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (IBAction)onButBack:(id)sender {
    if (mnPage == 0) {
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else {
        // go to prev page
        CGPoint pt = [self.mScrollView contentOffset];
        pt.x -= self.mScrollView.frame.size.width;
        
        [self.mScrollView setContentOffset:pt animated:YES];
        
        mnPage = 0;
        [self updateButton];
        [self updatePageControl];
    }
}

- (IBAction)onButNext:(id)sender {
    if (mnPage == 0) {
        // check if they are empty
        if (self.mTxtEmail.text.length == 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your email address"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (self.mTxtFirstName.text.length == 0)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your first name"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (self.mTxtLastName.text.length == 0)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your last name"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        if (!self.mUser) {
            if (self.mTxtPwd.text.length == 0)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your password"
                                                                message:@""
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
            if (![self.mTxtPwd.text isEqualToString:self.mTxtRepeatPwd.text])
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Password does not match"
                                                                message:@""
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
        
        if (!self.mSwitchAgree.on) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You must agree to our terms and conditions"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        // go to next page
        CGPoint pt = [self.mScrollView contentOffset];
        pt.x += self.mScrollView.frame.size.width;
        
        [self.mScrollView setContentOffset:pt animated:YES];
        
        mnPage = 1;
        [self updateButton];
        [self updatePageControl];
    }
    else {
        // create user
        UserData *user = self.mUser;
        
        if (!user) {
            user = (UserData *)[UserData user];
            mstrNameOld = [user getUsernameToShow];
        }
        
        user.username = self.mTxtEmail.text;
        user.email = self.mTxtEmail.text;
        user.firstname = self.mTxtFirstName.text;
        user.lastname = self.mTxtLastName.text;
        user.fullname = [NSString stringWithFormat:@"%@ %@",
                         self.mTxtFirstName.text,
                         self.mTxtLastName.text];
        user.phone = self.mTxtPhone.text;
        user.address = self.mTxtAddress.text;
        
        if (!self.mUser) {
            user.password = self.mTxtPwd.text;
        }
        
        user.about = self.mTxtAbout.text;
        
        if (mImgPhoto)
        {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            CommonUtils *utils = [CommonUtils sharedObject];
            
            // saving photo image
            UIImage* convertImage = [CommonUtils imageWithImage:mImgPhoto scaledToSize:utils.mszProfilePhoto];
            
            NSData *imageData = UIImageJPEGRepresentation(convertImage, 10);
            
            PFFile *imageFile = [PFFile fileWithName:@"photo.jpg" data:imageData];
            
            // Save PFFile
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                 if (!error)
                 {
                     // Create a PFObject around a PFFile and associate it with the current user
                     user.photo = imageFile;
                     [self saveUserInfo:user];
                 }
                 else{
                     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:[error userInfo][@"error"]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                     [alert show];
                 }
             }];
        }
        else {
            [self saveUserInfo:user];
        }
    }
}

- (void)saveUserInfo:(UserData *)user
{
    if (!self.mUser) {
        // location
    //    CommonUtils *utils = [CommonUtils sharedObject];
    //    [utils writeCurrentLocation:user needSave:NO];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (!error)
            {
                PFInstallation *installation = [PFInstallation currentInstallation];
                if (installation) {
                    installation[@"user"] = [UserData currentUser];
                    [installation saveInBackground];
                }
                
                [self performSegueWithIdentifier:@"Signup2Main" sender:nil];
            }
            else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[error userInfo][@"error"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    else {
        [user saveInBackground];
        
        NSString *strNameNew = [user getUsernameToShow];
        if (![strNameNew isEqualToString:mstrNameOld]) {
            
            // change username when changed
            PFQuery *query = [ItemData query];
            [query whereKey:@"user" equalTo:user];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error)
                 {
                     for (ItemData *object in objects)
                     {
                         object.username = strNameNew;
                         [object saveInBackground];
                     }
                 }
                 else
                 {
                     // Log details of the failure
                     NSLog(@"Error: %@ %@", error, [error userInfo]);
                 }
             }];
            
            query = [NotificationData query];
            [query whereKey:@"user" equalTo:user];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error)
                 {
                     for (NotificationData *object in objects)
                     {
                         object.username = strNameNew;
                         [object saveInBackground];
                     }
                 }
                 else
                 {
                     // Log details of the failure
                     NSLog(@"Error: %@ %@", error, [error userInfo]);
                 }
             }];
        }
        
        // pop to profile view controller
        NSArray *array = [self.navigationController viewControllers];
        [[self navigationController] popToViewController:array[array.count-2] animated:YES];
    }
}


- (void)updatePageControl {
    self.mPageControl.currentPage = mnPage;
}

- (void)updateButton {
    switch (mnPage) {
        case 0:
            [self.mButNext setTitle:@"NEXT STEP" forState:UIControlStateNormal];
            break;
            
        case 1:
            [self.mButNext setTitle:@"FINISH" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (IBAction)onButTakePhoto:(id)sender {
    [self shouldStartCameraController];
}

- (IBAction)onButChoosePhoto:(id)sender {
    [self shouldStartPhotoLibraryPickerController];
}

- (IBAction)onButLogout:(id)sender {
    // remove user from installation
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (installation) {
        [installation removeObjectForKey:@"user"];
        [installation saveInBackground];
    }
    
    [PFUser logOutInBackground];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.showsCameraControls = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    mImgPhoto = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self.mImgViewPhoto setImage:mImgPhoto];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - KeyBoard notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    const float movementDuration = 0.3f; // Standard duration for iOS
    
    if (notification) {
        // Get the size of the keyboard.
        mszKeyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    }
    
    // Given size may not account for screen rotation
    float keyboardHeight = MIN(mszKeyboard.height,mszKeyboard.width);
    
    // Get the position of current TextField, so we know if it will be hidden by the keyboard
    CGPoint p = [mTxtCurrent.superview convertPoint:mTxtCurrent.frame.origin toView:self.view];
    
    // Self explanatory
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    int availableSpace = screenHeight - keyboardHeight;
    
//    NSLog(@"y: %f, screenHeight: %d", p.y, screenHeight);
    
    int fieldHeight = mTxtCurrent.frame.size.height;
    int fieldBelowSpace = 10;
    int neededSpace = p.y + fieldHeight + fieldBelowSpace;
    
//    NSLog(@"availableSpace: %d, neededSpace:%d", availableSpace, neededSpace);
    
    if (availableSpace < neededSpace) {
        
        if (mbIsViewPushed) {
            return;
        }
        
        int spaceToAdd = availableSpace-neededSpace;
        
        // Flag to remember if we need to reset the view.
        mbIsViewPushed = YES;
        
        // Animation to push the view the spaceToAdd
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, spaceToAdd);
        [UIView commitAnimations];
        
        // Class variable accessible on the close function.
        mnPushedHeight = spaceToAdd;
    }
}

- (void)restoreViewPos {
    if (mbIsViewPushed) {
        mbIsViewPushed = NO;
        
        const float movementDuration = 0.3f; // tweak as needed
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, -mnPushedHeight);
        [UIView commitAnimations];
    }
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Get a reference to the currentField, so that we can dispose of using outlets.
    mTxtCurrent = textField;
    
    [self keyboardWillShow:nil];
}

// Reseting the view container if moved
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self restoreViewPos];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.mTxtEmail) {
        [self.mTxtFirstName becomeFirstResponder];
    }
    else if (textField == self.mTxtFirstName) {
        [self.mTxtLastName becomeFirstResponder];
    }
    else if (textField == self.mTxtLastName) {
        [self.mTxtPhone becomeFirstResponder];
    }
    else if (textField == self.mTxtPhone) {
        [self.mTxtAddress becomeFirstResponder];
    }
    else if (textField == self.mTxtAddress) {
        if (self.mUser) {
            [textField resignFirstResponder];
        }
        else {
            [self.mTxtPwd becomeFirstResponder];
        }
    }
    else if (textField == self.mTxtPwd) {
        [self.mTxtRepeatPwd becomeFirstResponder];
    }
    else if (textField == self.mTxtRepeatPwd) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewShouldBeginEditing:(UITextView *)textView {
    mTxtCurrent = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self restoreViewPos];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    if (newLength <= mnAboutMaxLen) {
        [self.mLblLeftLen setText:[NSString stringWithFormat:@"%lu", mnAboutMaxLen - newLength]];
        return YES;
    }
    else {
        return NO;
    }
}




@end
