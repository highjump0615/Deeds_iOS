//
//  FollowViewController.m
//  Deeds
//
//  Created by highjump on 15-5-4.
//
//

#import "FollowViewController.h"
#import "ProfileViewController.h"

#import "FollowUserCell.h"
#import "NavigationBarView.h"

#import "UserData.h"




@interface FollowViewController () {
    UserData *mUserSelected;
}

@property (weak, nonatomic) IBOutlet NavigationBarView *mViewNavBar;
@property (weak, nonatomic) IBOutlet UILabel *mLblNavBarTitle;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end


@implementation FollowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.mnType == FOLLOW_FOLLOWER) {
        [self.mLblNavBarTitle setText:@"Followers"];
    }
    else {
        [self.mLblNavBarTitle setText:@"Following"];
    }
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
    
    if ([[segue identifier] isEqualToString:@"Follow2Profile"]) {
        ProfileViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
        viewController.mUsername = [mUserSelected getUsernameToShow];
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger nCount = 0;
    
    if (self.mnType == FOLLOW_FOLLOWER) {
        nCount = [self.mUser.maryFollowerUser count];
    }
    else {
        nCount = [self.mUser.maryFollowingUser count];
    }
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowUserCell *followCell = (FollowUserCell *)[tableView dequeueReusableCellWithIdentifier:@"FollowCellID"];
    UserData *uData;
    
    if (self.mnType == FOLLOW_FOLLOWER) {
        uData = [self.mUser.maryFollowerUser objectAtIndex:indexPath.row];
    }
    else {
        uData = [self.mUser.maryFollowingUser objectAtIndex:indexPath.row];
    }
    [followCell fillContent:uData];
    
    return followCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.mnType == FOLLOW_FOLLOWER) {
        mUserSelected = [self.mUser.maryFollowerUser objectAtIndex:indexPath.row];
    }
    else {
        mUserSelected = [self.mUser.maryFollowingUser objectAtIndex:indexPath.row];
    }
    
    UserData *currentUser = [UserData currentUser];
    if ([mUserSelected.objectId isEqualToString:currentUser.objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Follow2Profile" sender:nil];
}



@end
