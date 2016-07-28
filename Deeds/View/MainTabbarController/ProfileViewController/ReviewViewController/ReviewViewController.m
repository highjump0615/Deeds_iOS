//
//  ReviewViewController.m
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import "ReviewViewController.h"
#import "RateViewController.h"
#import "ProfileViewController.h"

#import "ProfileInfoCell.h"
#import "ReviewCommentCell.h"

#import "UserData.h"
#import "NotificationData.h"


@interface ReviewViewController () {
    UserData *mUserSelected;
    NSString *mUsernameSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UIButton *mButRate;

@end

@implementation ReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    
    UserData *currentUser = [UserData currentUser];
    if ([self.mUser.objectId isEqualToString:currentUser.objectId]) {
        [self.mButRate setHidden:YES];
    }
    
    // get comment info
    PFRelation *relation = self.mUser.review;
    PFQuery *reviewQuery = [relation query];
    
    [reviewQuery orderByDescending:@"createdAt"];
    
    [reviewQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.mUser.maryReview removeAllObjects];
            
            for (NotificationData *notifyData in objects) {
                [self.mUser.maryReview addObject:notifyData];
            }
            
            [self.mTableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Review2Rate"]) {
        RateViewController *viewController = [segue destinationViewController];
        viewController.mUser = self.mUser;
    }
    else if ([[segue identifier] isEqualToString:@"Review2Profile"]) {
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

- (void)onButUser:(id)sender {
    NSInteger nTag = ((UIButton *)sender).tag;
    
    if (nTag >= 100) {
        NotificationData *notifyData = [self.mUser.maryReview objectAtIndex:nTag - 100];
        mUserSelected = notifyData.user;
        mUsernameSelected = notifyData.username;
    }
    
    UserData *currentUser = [UserData currentUser];
    if ([mUserSelected.objectId isEqualToString:currentUser.objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Review2Profile" sender:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [self.mUser.maryReview count];
}

- (UITableViewCell *)configureCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forHeight:(BOOL)bForHeight {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        ProfileInfoCell *infoCell = (ProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"ReviewProfileInfoCellID"];
        [infoCell fillContent:self.mUser username:@""];
        
        cell = infoCell;
    }
    else {
        ReviewCommentCell *itemCell = (ReviewCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"ReviewCommentCellID"];
        NotificationData *notifyData = [self.mUser.maryReview objectAtIndex:indexPath.row - 1];
        
        [itemCell fillContent:notifyData forHeight:bForHeight];
        
        if (!bForHeight) {
            [itemCell.mButUser addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
            [itemCell.mButUsername addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
            itemCell.mButUser.tag = indexPath.row - 1 + 100;
            itemCell.mButUsername.tag = indexPath.row - 1 + 100;
        }
        
        cell = itemCell;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if (indexPath.row == 0) {
        height = 148;
    }
    else {
        UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:YES];
        ReviewCommentCell *commentCell = (ReviewCommentCell *)cell;
        height = commentCell.mfHeight;
    }
    
    return height;
}


@end
