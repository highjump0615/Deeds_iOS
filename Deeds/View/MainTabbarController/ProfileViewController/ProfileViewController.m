//
//  ProfileViewController.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "ProfileViewController.h"
#import "AddItemViewController.h"
#import "SignupViewController.h"
#import "DetailViewController.h"
#import "FollowViewController.h"
#import "ReviewViewController.h"

#import "ProfileInfoCell.h"
#import "FavouriteCell.h"

#import "LoadingView.h"

#import "UserData.h"
#import "ItemData.h"


@interface ProfileViewController () <SWTableViewCellDelegate> {
    UIRefreshControl *mRefreshControl;
    
    NSMutableArray *maryItem;
    
    NSInteger mnCountOnce;
    NSInteger mnCurrentCount;
    BOOL mbNeedMore;
    
    ItemData *mItemSelected;
    FollowType mnFollowType;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@property (weak, nonatomic) IBOutlet UIButton *mButBack;
@property (weak, nonatomic) IBOutlet UIButton *mButEdit;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl setTintColor:[UIColor whiteColor]];
    [mRefreshControl addTarget:self action:@selector(getBlog:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];
    
    if (self.mUser) {
        [self.mButBack setHidden:NO];
        [self.mButEdit setHidden:YES];
    }
    else {
        [self.mButBack setHidden:YES];
        [self.mButEdit setHidden:NO];
    }
    
    maryItem = [[NSMutableArray alloc] init];
    
    // init
    mnCurrentCount = 0;
    mnCountOnce = 9;
    mbNeedMore = NO;
    
    [self getBlog:nil];
    
    if (self.mUser) {
        [self.mUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.mTableView reloadData];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mTableView reloadData];
    
    UserData *user = [UserData currentUser];
    if (self.mUser) {
        user = self.mUser;
        [user getFollowingUser:^{
            [self.mTableView reloadData];
        }];
    }
    
    // get follower
    [user getFollowerUser:^{
        [self.mTableView reloadData];
    }];
    
    // get review count
    PFRelation *relation = user.review;
    PFQuery *reviewQuery = [relation query];

    [reviewQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error) {
            user.mnReviewCount = number;
            [self.mTableView reloadData];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Profile2Add"]) {
        AddItemViewController *viewController = [segue destinationViewController];
        viewController.mItem = mItemSelected;
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Detail"]) {
        DetailViewController *viewController = [segue destinationViewController];
        viewController.mItem = mItemSelected;
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Edit"]) {
        SignupViewController *viewController = [segue destinationViewController];
        viewController.mUser = [UserData currentUser];
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Follow"]) {
        FollowViewController *viewController = [segue destinationViewController];
        viewController.mnType = mnFollowType;
        
        if (self.mUser) {
            viewController.mUser = self.mUser;
        }
        else {
            viewController.mUser = [UserData currentUser];
        }
    }
    else if ([[segue identifier] isEqualToString:@"Profile2Review"]) {
        ReviewViewController *viewController = [segue destinationViewController];
        
        if (self.mUser) {
            viewController.mUser = self.mUser;
        }
        else {
            viewController.mUser = [UserData currentUser];
        }
    }
}


- (void)getBlog:(UIRefreshControl *)sender {
    
    UserData *currentUser = [UserData currentUser];
    
    if (sender) { // refreshing
        mnCurrentCount = 0;
        
        UserData *uData = self.mUser;
        
        if (!uData) {
            uData = [UserData currentUser];
        }
    }
    
    //
    // get item data
    //
    PFQuery *query = [ItemData query];
    if (self.mUser) {
        [query whereKey:@"user" equalTo:self.mUser];
    }
    else {
        [query whereKey:@"user" equalTo:currentUser];
    }
    
    [query orderByDescending:@"createdAt"];
    
    query.skip = mnCurrentCount;
    query.limit = mnCountOnce;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopRefresh];
        
        if (!error) {
            
            if (sender) { // refreshing
                [maryItem removeAllObjects];
            }
            
            if ([objects count] > 0) {
                mbNeedMore = ([objects count] == mnCountOnce);
                
                for (ItemData *iData in objects) {
                    [maryItem addObject:iData];
                }
            }
            else {
                mbNeedMore = NO;
            }
            
            mnCurrentCount = [maryItem count];
            [self.mTableView reloadData];
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error localizedDescription]);
        }
    }];
}

- (void)stopRefresh {
    [mRefreshControl endRefreshing];
}

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)onButFollowing:(id)sender {
    
    UserData *uData = self.mUser;
    if (!uData) {
        uData = [UserData currentUser];
    }
    
    if ([uData.maryFollowingUser count] == 0) {
        return;
    }
    
    mnFollowType = FOLLOW_FOLLOWING;
    [self performSegueWithIdentifier:@"Profile2Follow" sender:nil];
}

- (void)onButFollower:(id)sender {
    
    UserData *uData = self.mUser;
    if (!uData) {
        uData = [UserData currentUser];
    }
    
    if ([uData.maryFollowerUser count] == 0) {
        return;
    }
    
    mnFollowType = FOLLOW_FOLLOWER;
    [self performSegueWithIdentifier:@"Profile2Follow" sender:nil];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:255/255.0 green:195/255.0 blue:13/255.0 alpha:1.0]
                                                icon:[UIImage imageNamed:@"profile_list_edit_but.png"]];
    
    return rightUtilityButtons;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + [maryItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        ProfileInfoCell *infoCell = (ProfileInfoCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileInfoCellID"];
        if (!self.mUser) {
            [infoCell fillContent:[UserData currentUser] username:@""];
        }
        else {
            [infoCell fillContent:self.mUser username:self.mUsername];
        }
        
        [infoCell.mButFollowing addTarget:self action:@selector(onButFollowing:) forControlEvents:UIControlEventTouchUpInside];
        [infoCell.mButFollower addTarget:self action:@selector(onButFollower:) forControlEvents:UIControlEventTouchUpInside];
        
        cell = infoCell;
    }
    else {
        FavouriteCell *itemCell = (FavouriteCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileItemCellID"];
        ItemData *item = [maryItem objectAtIndex:indexPath.row - 1];
        [itemCell fillContent:item];
        
        if (!self.mUser) {
            // optionally specify a width that each set of utility buttons will share
            [itemCell setRightUtilityButtons:[self rightButtons] WithButtonWidth:105.0f];
            itemCell.delegate = self;
        }
        
        cell = itemCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if (indexPath.row == 0) {
        height = 270;
        
        if (!self.mUser) {
            height -= 45;
        }
    }
    else {
        height = 66;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        return;
    }
    
    mItemSelected = [maryItem objectAtIndex:indexPath.row - 1];
    [self performSegueWithIdentifier:@"Profile2Detail" sender:nil];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat fHeight = 0;
    
    if (mbNeedMore) {
        fHeight = 50;
    }
    
    return fHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view;
    
    if (mbNeedMore) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        view = [LoadingView loadingView:screenWidth];
        [self getBlog:nil];
    }
    
    return view;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.mTableView indexPathForCell:cell];
            mItemSelected = [maryItem objectAtIndex:cellIndexPath.row - 1];
            [self performSegueWithIdentifier:@"Profile2Add" sender:nil];
            
            [cell hideUtilityButtonsAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return NO;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}


@end
