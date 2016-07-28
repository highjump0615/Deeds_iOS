//
//  RateViewController.m
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import "RateViewController.h"

#import "RateProfileInfoCell.h"
#import "RateSliderCell.h"
#import "RateCommentCell.h"

#import "MBProgressHUD.h"

#import "UserData.h"
#import "NotificationData.h"


@interface RateViewController () <RateSliderCellDelegate> {
    UITextView *mTxtComment;
    BOOL mbIsViewPushed;
    int mnPushedHeight;
    
    NSString *mstrComment;
    RateType mnRateType;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *mButSubmit;

@end

@implementation RateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    
    [self.mButSubmit.layer setMasksToBounds:YES];
    [self.mButSubmit.layer setCornerRadius:3];
    
    // keybaord
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    mnRateType = RATE_NORMAL;
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

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButSubmit:(id)sender {
    if ([mstrComment length] == 0) {
        return;
    }
    
    //
    // save to notification database
    //
    UserData *currentUser = [UserData currentUser];
    
    NotificationData *notifyObj = [NotificationData object];
    notifyObj.user = currentUser;
    notifyObj.username = [currentUser getUsernameToShow];
    notifyObj.targetuser = self.mUser;
    notifyObj.type = NOTIFICATION_RATE;
    notifyObj.comment = mstrComment;
    notifyObj.rate = mnRateType;
    
    [notifyObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:[error userInfo][@"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        else {
            //
            // send notification to favourite user
            //
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"user" equalTo:self.mUser];
            
            // Send the notification.
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"You have been given a rating", @"alert",
                                  @"rate", @"notifyType",
                                  currentUser.objectId, @"notifyItem",
                                  @"Increment", @"badge",
                                  @"cheering.caf", @"sound",
                                  nil];
            [push setData:data];
            
            [push sendPushInBackground];
            
            //
            // add review object
            //
            [PFCloud callFunctionInBackground:@"addReviewToUser"
                               withParameters:@{@"userId":self.mUser.objectId,
                                                @"notifyId":notifyObj.objectId}
                                        block:^(id object, NSError *error)
             {
                 if (error) {
                     NSLog(@"%@", error);
                 }
             }];
            
            [self.mUser.maryReview insertObject:notifyObj atIndex:0];
            
            self.mUser.mnReviewCount++;
//            NSInteger nReviewCount = [self.mUser.reviewcount integerValue];
//            self.mUser.reviewcount = [NSNumber numberWithInteger:nReviewCount + 1];
            
            [self onButBack:nil];
        }
    }];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    const float movementDuration = 0.3f; // Standard duration for iOS
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // Given size may not account for screen rotation
    float keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    // Get the position of current TextField, so we know if it will be hidden by the keyboard
    CGPoint p = [mTxtComment.superview convertPoint:mTxtComment.frame.origin toView:self.view];
    
    // Self explanatory
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    int availableSpace = screenHeight - keyboardHeight;
    
    int fieldHeight = mTxtComment.frame.size.height;
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

- (void)restoreViewPos {
    if (mbIsViewPushed) {
        mbIsViewPushed = NO;
        
        const float movementDuration = 0.3f; // tweak as needed
        [UIView beginAnimations: @"anim" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        //        self.view.frame = CGRectOffset(self.view.frame, 0, -mnPushedHeight);
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     0,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
        [UIView commitAnimations];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        RateProfileInfoCell *infoCell = (RateProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"RateProfileInfoCellID"];
        [infoCell fillContent:self.mUser username:@""];
        
        cell = infoCell;
    }
    else if (indexPath.row == 1) {
        RateSliderCell *sliderCell = (RateSliderCell *)[tableView dequeueReusableCellWithIdentifier:@"RateSliderCellID"];
        [sliderCell.mLblTitle  setText:[NSString stringWithFormat:@"Your Experience About %@", [self.mUser getUsernameToShow]]];
        [sliderCell setDelegate:self];
        
        cell = sliderCell;
    }
    else if (indexPath.row == 2) {
        RateCommentCell *commentCell = (RateCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"RateCommentCellID"];
        
        cell = commentCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    if (indexPath.row == 0) {
        height = 148 + (screenHeight - 480) / 2;
    }
    else if (indexPath.row == 1) {
        height = 77;
    }
    else if (indexPath.row == 2) {
        height = 126 + (screenHeight - 480) / 2;
    }
    
    return height;
}


#pragma mark - UITextViewDelegate

- (void)textViewShouldBeginEditing:(UITextView *)textView {
    mTxtComment = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self restoreViewPos];
    
    mstrComment = textView.text;
}


#pragma mark - RateSliderCellDelegate

- (void)setRateType:(NSInteger)value {
    mnRateType = (RateType)value;
}

@end
