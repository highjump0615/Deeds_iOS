//
//  ForgetViewController.m
//  Deeds
//
//  Created by highjump on 15-4-10.
//
//

#import "ForgetViewController.h"

#import "UserData.h"


@interface ForgetViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mTxtEmail;
@property (weak, nonatomic) IBOutlet UIButton *mButReset;

@end

@implementation ForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // reset button
    [self.mButReset.layer setMasksToBounds:YES];
    [self.mButReset.layer setCornerRadius:3];
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (IBAction)onButReset:(id)sender {
    // check if they are empty
    if (self.mTxtEmail.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input your email address"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [UserData requestPasswordResetForEmailInBackground:self.mTxtEmail.text];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Request has been submitted"
                                                    message:@""
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.mTxtEmail isFirstResponder] && [touch view] != self.mTxtEmail) {
        [self.mTxtEmail resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}


@end
