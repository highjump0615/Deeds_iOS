//
//  DetailViewController.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "DetailViewController.h"
#import "ProfileViewController.h"

#import <MessageUI/MFMailComposeViewController.h>

#import "DetailContactView.h"
#import "FullImageView.h"
#import "NavigationBarView.h"
#import "MentionListView.h"

#import "DetailItemCell.h"
#import "DetailUserCell.h"
#import "DetailCommentCell.h"
#import "MentionCell.h"

#import "UserData.h"
#import "ItemData.h"
#import "NotificationData.h"


@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate> {
    UITextField *mTxtComment;
    BOOL mbIsViewPushed;
    int mnPushedHeight;
    
    UserData *mUserSelected;
    NSString *mUsernameSelected;
    
    NSMutableArray *maryCommentData;
    
    CGFloat mfKeyboardHeight;
    
    MentionListView *mViewMention;
    CGFloat mfMaxMentionHeight;
    NSMutableArray *maryMentionUser;
    NSInteger mnAtPos;
    NSString *mstrAtText;
}

@property (weak, nonatomic) IBOutlet NavigationBarView *mViewNavBar;

@property (weak, nonatomic) IBOutlet UIView *mViewButton;
@property (weak, nonatomic) IBOutlet UIButton *mButWant;

@property (weak, nonatomic) IBOutlet DetailContactView *mViewContact;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // keybaord
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self.mButWant.layer setMasksToBounds:YES];
    [self.mButWant.layer setCornerRadius:5];
    
    [self.mViewContact initView];

    //
    // mention list
    //
    mnAtPos = 0;
    mstrAtText = @"";
    
    UserData *currentUser = [UserData currentUser];
    maryMentionUser = [[NSMutableArray alloc] initWithArray:currentUser.maryFollowingUser];
    
    maryCommentData = [[NSMutableArray alloc] init];
    
    // get comment info
    PFRelation *relation = self.mItem.commentobject;
    PFQuery *commentQuery = [relation query];
    
    [commentQuery includeKey:@"user"];
    [commentQuery orderByDescending:@"createdAt"];
    
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [maryCommentData removeAllObjects];
            
            for (NotificationData *notifyData in objects) {
                if (notifyData.type == NOTIFICATION_COMMENT) {
                    [maryCommentData addObject:notifyData];
                }
                
                if ([self isExistinginMentionList:notifyData.user]) {
                    continue;
                }
                
                [maryMentionUser addObject:notifyData.user];
            }
            
            [self.mTableView reloadData];
        }
    }];
    
    //
    // user info
    //
    [self.mItem.user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        [self.mViewContact setContent:self.mItem];
        [self.mTableView reloadData];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

- (void)viewDidLayoutSubviews {
    // shadow on view
    CGRect rtShadow = self.mViewButton.bounds;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
    self.mViewButton.layer.masksToBounds = NO;
    self.mViewButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mViewButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.mViewButton.layer.shadowOpacity = 0.3f;
    self.mViewButton.layer.shadowPath = shadowPath.CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (BOOL)isExistinginMentionList:(UserData *)user {
    
    BOOL bExisting = NO;
    UserData *currentUser = [UserData currentUser];
    
    if ([user.objectId isEqualToString:currentUser.objectId]) {
        return YES;
    }
    
    for (UserData *uData in maryMentionUser) {
        if ([uData.objectId isEqualToString:user.objectId]) {
            bExisting = YES;
            break;
        }
    }
    
    return bExisting;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Detail2Profile"]) {
        ProfileViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
        viewController.mUsername = mUsernameSelected;
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButWant:(id)sender {
    [self.mViewContact showView:YES animated:YES];
}

- (IBAction)onButPhone:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text length] == 0) {
        return;
    }
    
    NSString *phoneNumber = [@"tel:" stringByAppendingString:button.titleLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (IBAction)onButEmail:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text length] == 0) {
        return;
    }
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:self.mItem.title];
    
    NSArray *usersTo = [NSArray arrayWithObject:self.mItem.user.email];
    [controller setToRecipients:usersTo];
    
    NSString* strMsg = [NSString stringWithFormat:@""];
    [controller setMessageBody:strMsg isHTML:NO];
    
    if (controller) {
        [self.navigationController presentViewController: controller animated: YES completion:^{
        }];
    }
}

- (void)keyboardWillShow:(NSNotification*)notification {
    const float movementDuration = 0.3f; // Standard duration for iOS
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // Given size may not account for screen rotation
    mfKeyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    // Get the position of current TextField, so we know if it will be hidden by the keyboard
    CGPoint p = [mTxtComment.superview convertPoint:mTxtComment.frame.origin toView:self.view];
    
    // Self explanatory
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    int availableSpace = screenHeight - mfKeyboardHeight;
    
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
        
        mnPushedHeight = 0;
    }
}

- (void)didRecognizeSingleTap:(UITapGestureRecognizer *)sender {
    
    [self dismissKeyboard:nil];
    
    UIImageView *imgView = (UIImageView *)sender.view;
    
    CGRect rtFrame = imgView.frame;
    rtFrame.origin.y += self.mViewNavBar.frame.size.height;
    
    FullImageView *fullView = (FullImageView *)[FullImageView initView:self.view];
    [fullView setItemParseImages:self.mItem.images];
    [fullView showView:rtFrame index:imgView.tag];
}

- (void)showMentionView:(BOOL)bShow {
    if (bShow) {
        if (mViewMention) {
            return;
        }
        
        //
        // calculate frame size
        //
        // Get the position of current TextField, so we know if it will be hidden by the keyboard
        CGPoint p = [mTxtComment.superview convertPoint:mTxtComment.frame.origin toView:self.view];
        CGFloat fUpSpace = p.y - MAX(-mnPushedHeight, self.mViewNavBar.frame.size.height) - 5;
        
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        CGFloat fTextFieldHeight = mTxtComment.frame.size.height;
        CGFloat fDownSpace = screenHeight - (p.y + mnPushedHeight) - fTextFieldHeight - mfKeyboardHeight - 5;
        
//        NSLog(@"%f, %f", fUpSpace, fDownSpace);
        
        CGRect rtFrame;
        if (fUpSpace > fDownSpace) {
            mfMaxMentionHeight = fUpSpace;
            rtFrame = CGRectMake(p.x, p.y - fUpSpace, mTxtComment.frame.size.width, fUpSpace);
            mViewMention = (MentionListView *)[MentionListView viewWithFrame:rtFrame position:YES];
        }
        else {
            mfMaxMentionHeight = fDownSpace;
            rtFrame = CGRectMake(p.x, p.y + fTextFieldHeight, mTxtComment.frame.size.width, fDownSpace);
            mViewMention = (MentionListView *)[MentionListView viewWithFrame:rtFrame position:NO];
        }
        
        [mViewMention.mTableView setDataSource:self];
        [mViewMention.mTableView setDelegate:self];
        [self.view addSubview:mViewMention];
    }
    else {
        if (mViewMention) {
            [mViewMention removeFromSuperview];
            mViewMention = nil;
        }
    }
}

#pragma mark - TextField

// Reseting the view container if moved
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self restoreViewPos];
    
    [self showMentionView:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    // save comment data
    if ([textField.text length] == 0) {
        return YES;
    }
    
    //
    // save to notification database
    //
    UserData *currentUser = [UserData currentUser];
    
    NotificationData *notifyObj = [NotificationData object];
    notifyObj.item = self.mItem;
    notifyObj.user = currentUser;
    notifyObj.username = [currentUser getUsernameToShow];
    notifyObj.targetuser = self.mItem.user;
    notifyObj.type = NOTIFICATION_COMMENT;
    notifyObj.comment = textField.text;
    
    [notifyObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
            // add comment object
            //
            PFRelation *relation = self.mItem.commentobject;
            [relation addObject:notifyObj];
            
            // set popularity
            [self.mItem saveInBackground];
        }
    }];
    
    [maryCommentData insertObject:notifyObj atIndex:0];
    //    [self.mTableView reloadData];
    
    [self.mTableView beginUpdates];
    
    NSArray *aryIndexPath = [[NSArray alloc] initWithObjects:
                             [NSIndexPath indexPathForRow:2 inSection:0],
                             nil];
    [self.mTableView insertRowsAtIndexPaths:aryIndexPath
                           withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.mTableView endUpdates];
    
    // if it is me, return
    if (![self.mItem.user.objectId isEqualToString:currentUser.objectId]) {
        //
        // send notification to favourite user
        //
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"user" equalTo:self.mItem.user];
        
        // Send the notification.
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:query];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@ left you a little something", [currentUser getUsernameToShow]], @"alert",
                              @"comment", @"notifyType",
                              self.mItem.objectId, @"notifyItem",
                              @"Increment", @"badge",
                              @"cheering.caf", @"sound",
                              nil];
        [push setData:data];
        
        [push sendPushInBackground];
    }
    
    //
    // check mentioning and send notification
    //
    NSString *strCommentText = textField.text;
    
    while (1)
    {
        NSRange range = [strCommentText rangeOfString:@"@"];
        
        if (range.location == NSNotFound)
        {
            break;
        }
        else
        {
            NSString *strToCompare = [strCommentText substringFromIndex:range.location + 1];
            for (UserData *uData in maryMentionUser) {
                NSRange mentionRange = [strToCompare rangeOfString:[uData getUsernameToShow]];
                if (mentionRange.location == 0) {
                    
                    NotificationData *mentionObj = [NotificationData object];
                    mentionObj.item = self.mItem;
                    mentionObj.user = currentUser;
                    mentionObj.username = [currentUser getUsernameToShow];
                    mentionObj.targetuser = uData;
                    mentionObj.type = NOTIFICATION_MENTION;
                    mentionObj.comment = textField.text;
                    [mentionObj saveInBackground];
                    
                    // send notification to commented user
                    PFQuery *query = [PFInstallation query];
                    [query whereKey:@"user" equalTo:uData];
                    
                    // Send the notification.
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:query];
                    
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"Your name has been mentioned", @"alert",
                                          @"mention", @"notifyType",
                                          self.mItem.objectId, @"notifyBlog",
                                          @"Increment", @"badge",
                                          @"cheering.caf", @"sound",
                                          nil];
                    [push setData:data];
                    [push sendPushInBackground];
                    
                    break;
                }
            }
            
            strCommentText = strToCompare;
        }
    }
    
    [textField setText:@""];
    
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)text
{
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    if ([text isEqualToString:@"@"]) {
        
        if (mViewMention) {
            return YES;
        }
        
        if ([maryMentionUser count] == 0) {
            return YES;
        }
        
        mnAtPos = newLength;
        
        [self showMentionView:YES];
    }
    
    if (newLength < mnAtPos) {
        [self showMentionView:NO];
        mnAtPos = 0;
    }
    
    // extract the at text
    if (mnAtPos > 0) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:text];
        
        mstrAtText = [newString substringFromIndex:mnAtPos];
        
        [self showMentionView:YES];
        [mViewMention.mTableView reloadData];
    }
    
    return YES;
}


#pragma mark -

- (void)onButUser:(id)sender {
    
    [self dismissKeyboard:nil];
    
    NSInteger nTag = ((UIButton *)sender).tag;
    
    if (nTag >= 100) {
        NotificationData *notifyData = [maryCommentData objectAtIndex:nTag - 100];
        mUserSelected = notifyData.user;
        mUsernameSelected = notifyData.username;
    }
    else {
        mUserSelected = self.mItem.user;
        mUsernameSelected = self.mItem.username;
    }
    
    UserData *currentUser = [UserData currentUser];
    if ([mUserSelected.objectId isEqualToString:currentUser.objectId]) {
        return;
    }

    [self performSegueWithIdentifier:@"Detail2Profile" sender:nil];
}

- (UserData *)getAtUserWithRowNum:(NSInteger)nRow {
    
    UserData *resData;
    
    int nCount = 0;
    
    // get user from follow data
    for (UserData *uData in maryMentionUser) {
        
        if (mstrAtText.length > 0) {
            NSRange range = [[uData getUsernameToShow] rangeOfString:mstrAtText options:NSCaseInsensitiveSearch];
            if (range.location != 0) {
                continue;
            }
        }
        
        if (nCount == nRow) {
            resData = uData;
            break;
        }
        
        nCount++;
    }
    
    return resData;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger nCount = 0;
    
    if (tableView == self.mTableView) {
        nCount = 2 + [maryCommentData count];
    }
    else {
        // get user from mention list
        for (UserData *uData in maryMentionUser) {
            
            if (mstrAtText.length > 0) {
                NSRange range = [[uData getUsernameToShow] rangeOfString:mstrAtText
                                                                 options:NSCaseInsensitiveSearch];
                if (range.location == 0) {
                    nCount++;
                }
            }
            else {
                nCount++;
            }
        }
        
        if (nCount > 0 && mnAtPos > 0) {
            [self showMentionView:YES];
            
            CGFloat fViewMentionHeight = MIN(mfMaxMentionHeight, nCount * 38 + 9);
            [mViewMention setViewHeight:fViewMentionHeight];
        }
        else {
            [self showMentionView:NO];
        }
    }
    
    return nCount;
}

- (UITableViewCell *)configureCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forHeight:(BOOL)bForHeight {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        DetailItemCell *itemCell = (DetailItemCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailItemCellID"];
        [itemCell fillContent:self.mItem forHeight:bForHeight];
        [itemCell setDelegate:self];
        
        // add tap recognizer to images
        if ([itemCell.mImgView1.gestureRecognizers count] == 0) {
            [itemCell.mImgView1 setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(didRecognizeSingleTap:)];
            [singleTapRecognizer setNumberOfTapsRequired:1];
            [itemCell.mImgView1 addGestureRecognizer:singleTapRecognizer];
            itemCell.mImgView1.tag = 0;
        }
        
        if ([itemCell.mImgView2.gestureRecognizers count] == 0) {
            [itemCell.mImgView2 setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(didRecognizeSingleTap:)];
            [singleTapRecognizer setNumberOfTapsRequired:1];
            [itemCell.mImgView2 addGestureRecognizer:singleTapRecognizer];
            itemCell.mImgView2.tag = 1;
        }
        
        if ([itemCell.mImgView3.gestureRecognizers count] == 0) {
            [itemCell.mImgView3 setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self action:@selector(didRecognizeSingleTap:)];
            [singleTapRecognizer setNumberOfTapsRequired:1];
            [itemCell.mImgView3 addGestureRecognizer:singleTapRecognizer];
            itemCell.mImgView3.tag = 2;
        }

    
        cell = itemCell;
    }
    else if (indexPath.row == 1) {
        DetailUserCell *userCell = (DetailUserCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailUserCellID"];
        [userCell fillContent:self.mItem];
        mTxtComment = userCell.mTxtComment;

        if (!bForHeight) {
            [userCell.mButUser addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
            userCell.mButUser.tag = 0;
        }
        
        cell = userCell;
    }
    else {
        DetailCommentCell *commentCell = (DetailCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailCommentCellID"];
        NotificationData *notifyData = [maryCommentData objectAtIndex:indexPath.row - 2];
        
        [commentCell fillContent:notifyData forHeight:bForHeight];
        
        if (!bForHeight) {
            [commentCell.mButUser addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
            commentCell.mButUser.tag = indexPath.row - 2 + 100;
        }
        
        cell = commentCell;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if (tableView == self.mTableView) {
        cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:NO];
    }
    else {
        NSString *strCellID = @"MentionCellID";
        
        MentionCell *mentionCell = (MentionCell *)[tableView dequeueReusableCellWithIdentifier:strCellID];
        if (!mentionCell) {
            [tableView registerNib:[UINib nibWithNibName:@"MentionCell" bundle:nil] forCellReuseIdentifier:strCellID];
            mentionCell = (MentionCell *)[tableView dequeueReusableCellWithIdentifier:strCellID];
        }
        
        UserData *uData = [self getAtUserWithRowNum:indexPath.row];
        [mentionCell fillContent:uData];
        
        cell = mentionCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if (tableView == self.mTableView) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:YES];
            DetailItemCell *itemCell = (DetailItemCell *)cell;
            height = itemCell.mfHeight;
        }
        else if (indexPath.row == 1) {
            height = 182;
        }
        else {
            UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:YES];
            DetailCommentCell *commentCell = (DetailCommentCell *)cell;
            height = commentCell.mfHeight;
        }
        
        if (height == 0) {
    //        UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:YES];
    //        if (cell) {
    //            [cell layoutIfNeeded];
    //            height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    ////            height += 1;
    //        }
        }
    }
    else {
        height = 38;
    }
    
    return height;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCellEditingStyle editingStyle = UITableViewCellEditingStyleNone;
    
    if (tableView != self.mTableView) {
        return editingStyle;
    }
    
    UserData *currentUser = [UserData currentUser];
    
    if ([self.mItem.user.objectId isEqualToString:currentUser.objectId]) {
        editingStyle = UITableViewCellEditingStyleDelete;
        return editingStyle;
    }
    
    if (indexPath.row < 2) {
        return editingStyle;
    }
    
    NotificationData *notifyData = [maryCommentData objectAtIndex:indexPath.row - 2];
    if ([notifyData.user.objectId isEqualToString:currentUser.objectId]) {
        editingStyle = UITableViewCellEditingStyleDelete;
    }
    
    return editingStyle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (tableView != self.mTableView) {
            return;
        }
        
        NotificationData *notifyData = [maryCommentData objectAtIndex:indexPath.row - 2];
        
        // remove cell
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:deleteIndexPaths
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [notifyData deleteInBackground];
        [maryCommentData removeObjectAtIndex:indexPath.row - 2];
        
        [tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.mTableView) {
        return;
    }
    
    UserData *uData = [self getAtUserWithRowNum:indexPath.row];
    
    NSString *strUser = [uData getUsernameToShow];
    NSString *strText;
    
    strText = [NSString stringWithFormat:@"%@%@", [mTxtComment.text substringToIndex:mnAtPos], strUser];
    [mTxtComment setText:strText];
    
    [self showMentionView:NO];
    mnAtPos = 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mTableView) {
        [self dismissKeyboard:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result != MFMailComposeResultSent) {
        //        NSString *strMessage;
        //
        //        if (controller == mailerShare) {
        //            strMessage = @"Email Share has been failed.";
        //        }
        //        else {
        //            strMessage = @"Report has been failed.";
        //        }
        //
        //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email Share has been failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alert show];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!mViewMention) {
        return YES;
    }
    
    CGPoint pt = [touch locationInView:self.view];
    if (CGRectContainsPoint(mViewMention.frame, pt)) {
        return NO;
    }

    return YES;
}



@end
