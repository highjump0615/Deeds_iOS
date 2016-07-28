//
//  SigninViewController.m
//  Deeds
//
//  Created by highjump on 15-4-9.
//
//

#import "SigninViewController.h"
#import "NavigationBarView.h"
#import "MBProgressHUD.h"

#import "UserData.h"

@interface SigninViewController () {
    UITextField *mTxtCurrent;
    BOOL mbIsViewPushed;
    int mnPushedHeight;
}

@property (weak, nonatomic) IBOutlet NavigationBarView *mViewNavBar;

@property (weak, nonatomic) IBOutlet UIButton *mButContinue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstTopLogo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstLogoWelcome;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstTextEmail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstEmailPwd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstPwdForget;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstForgetContinue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstContinueSignup;

@property (weak, nonatomic) IBOutlet UITextField *mTxtEmail;
@property (weak, nonatomic) IBOutlet UITextField *mTxtPassword;

@end

@implementation SigninViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // continue button
    [self.mButContinue.layer setMasksToBounds:YES];
    [self.mButContinue.layer setCornerRadius:3];
    
    // regulate space
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat fConstraint;
    CGFloat fOriginalHeight = self.mCstTopLogo.constant
                            + self.mCstLogoWelcome.constant
                            + self.mCstTextEmail.constant
                            + self.mCstEmailPwd.constant
                            + self.mCstPwdForget.constant
                            + self.mCstForgetContinue.constant
                            + self.mCstContinueSignup.constant;
    CGFloat fDiff = 568 - fOriginalHeight;
    screenHeight -= fDiff;
    
    fConstraint = self.mCstTopLogo.constant / fOriginalHeight * screenHeight;
    [self.mCstTopLogo setConstant:fConstraint];
    fConstraint = self.mCstLogoWelcome.constant / fOriginalHeight * screenHeight;
    [self.mCstLogoWelcome setConstant:fConstraint];
    fConstraint = self.mCstTextEmail.constant / fOriginalHeight * screenHeight;
    [self.mCstTextEmail setConstant:fConstraint];
    fConstraint = self.mCstEmailPwd.constant / fOriginalHeight * screenHeight;
    [self.mCstEmailPwd setConstant:fConstraint];
    fConstraint = self.mCstPwdForget.constant / fOriginalHeight * screenHeight;
    [self.mCstPwdForget setConstant:fConstraint];
    fConstraint = self.mCstForgetContinue.constant / fOriginalHeight * screenHeight;
    [self.mCstForgetContinue setConstant:fConstraint];
    fConstraint = self.mCstContinueSignup.constant / fOriginalHeight * screenHeight;
    [self.mCstContinueSignup setConstant:fConstraint];
    
    // keybaord
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButContinue:(id)sender {
    // check if they are empty
    if (self.mTxtEmail.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your email address"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.mTxtPassword.text.length == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your password"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [UserData logInWithUsernameInBackground:self.mTxtEmail.text
                                   password:self.mTxtPassword.text
                                      block:^(PFUser *user, NSError *error)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!error)
        {
            PFInstallation *installation = [PFInstallation currentInstallation];
            if (installation) {
                installation[@"user"] = [UserData currentUser];
                [installation saveInBackground];
            }
            [self performSegueWithIdentifier:@"Signin2Main" sender:nil];
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


#pragma mark - KeyBoard notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    const float movementDuration = 0.3f; // Standard duration for iOS
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // Get the position of the keyboard.  Needed for iOS 8 QuickType fields.
//    CGPoint keyboardCoords = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin;
    
    // Given size may not account for screen rotation
    float keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    // Get the position of current TextField, so we know if it will be hidden by the keyboard
    CGPoint p = [mTxtCurrent.superview convertPoint:mTxtCurrent.frame.origin toView:self.view];
    
    // Self explanatory
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    int availableSpace = screenHeight - keyboardHeight;
    
    int fieldHeight = mTxtCurrent.frame.size.height;
    int fieldBelowSpace = 10;
    int neededSpace = p.y + fieldHeight + fieldBelowSpace;
    
    if (availableSpace < neededSpace) {
        
        int spaceToAdd = availableSpace-neededSpace;
        
        // This fixes collition animation between keyboards with and without QuickType
//        if (screenHeight != keyboardCoords.y) {
//            spaceToAdd -= (screenHeight - keyboardCoords.y) - keyboardHeight;
//        }
        
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

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Get a reference to the currentField, so that we can dispose of using outlets.
    mTxtCurrent = textField;
}

// Reseting the view container if moved
- (void)textFieldDidEndEditing:(UITextField *)textField
{
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.mTxtEmail) {
        [self.mTxtPassword becomeFirstResponder];
    }
    else if (textField == self.mTxtPassword) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.mTxtEmail isFirstResponder] && [touch view] != self.mTxtEmail) {
        [self.mTxtEmail resignFirstResponder];
    }
    
    if ([self.mTxtPassword isFirstResponder] && [touch view] != self.mTxtPassword) {
        [self.mTxtPassword resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}



@end
