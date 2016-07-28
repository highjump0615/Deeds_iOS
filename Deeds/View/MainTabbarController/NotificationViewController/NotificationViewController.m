//
//  NotificationViewController.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "NotificationViewController.h"
#import "ProfileViewController.h"
#import "DetailViewController.h"
#import "ReviewViewController.h"

#import "NotificationCell.h"
#import "NotificationCommentCell.h"
#import "LoadingView.h"

#import "NotificationData.h"
#import "UserData.h"

@interface NotificationViewController () {
    UIRefreshControl *mRefreshControl;
    
    NSMutableArray *maryNotify;
    
    NSInteger mnCountOnce;
    NSInteger mnCurrentCount;
    BOOL mbNeedMore;
    
    NotificationData *mPrevNotify;
    
    ItemData *mItemSelected;
    UserData *mUserSelected;
    NSString *mUsernameSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    maryNotify = [[NSMutableArray alloc] init];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl addTarget:self action:@selector(getNotification:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];
    
    [self.mTableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
    [self.mTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mTableView.bounds.size.width, 0.01f)]];
//    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // init
    mnCurrentCount = 0;
    mnCountOnce = 13;
    mbNeedMore = NO;
    
    [self getNotification:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (currentInstallation.badge > 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}


- (void)stopRefresh {
    [mRefreshControl endRefreshing];
}

- (void)alertForDelete {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot find this item"
                                                   message:@""
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"Notify2Profile"]) {
        ProfileViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
        viewController.mUsername = mUsernameSelected;
    }
    else if ([[segue identifier] isEqualToString:@"Notify2Detail"]) {
        DetailViewController *viewController =  [segue destinationViewController];
        viewController.mItem = mItemSelected;
    }
    else if ([[segue identifier] isEqualToString:@"Notify2Review"]) {
        ReviewViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)getNotification:(UIRefreshControl *)sender {
    UserData *currentUser = [UserData currentUser];
    
    if (sender) { // refreshing
        [maryNotify removeAllObjects];
        mnCurrentCount = 0;
    }
    
    //
    // get item data
    //
    PFQuery *query = [NotificationData query];
    [query whereKey:@"targetuser" equalTo:currentUser];
    [query whereKey:@"type" lessThanOrEqualTo:@(NOTIFICATION_MENTION)];
    [query includeKey:@"user"];
    [query includeKey:@"item"];

    [query orderByDescending:@"createdAt"];
    
    query.skip = mnCurrentCount;
    query.limit = mnCountOnce;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopRefresh];
        
        if (!error) {
            
            if ([objects count] > 0) {
                mbNeedMore = ([objects count] == mnCountOnce);
                
                for (NotificationData *nData in objects) {
                    [maryNotify addObject:nData];
                }
            }
            else {
                mbNeedMore = NO;
            }
            
            mnCurrentCount = [maryNotify count];
            [self.mTableView reloadData];
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error localizedDescription]);
        }
    }];
}

- (NSInteger)getNotificationCount {
    NSInteger nCount = 0;
    
    for (NotificationData *nData in maryNotify) {
        if (nData.mbExpanded) {
            nCount++;
        }
        
        nCount++;
    }
    
    return nCount;
}

- (NotificationData *)getNotificationAtIndex:(NSInteger)index {
    NotificationData *nData;
    NSInteger nIndex = 0;
    
    for (NotificationData *ntData in maryNotify) {
        if (nIndex == index) {
            nData = ntData;
            break;
        }
        
        if (ntData.mbExpanded) {
            nIndex++;
            if (nIndex == index) {
                mPrevNotify = ntData;
                nData = nil;
                break;
            }
        }
        
        nIndex++;
    }
    
    return nData;
}

- (void)gotoProfile {
    UserData *currentUser = [UserData currentUser];
    if ([currentUser.objectId isEqualToString:mUserSelected.objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Notify2Profile" sender:nil];
}

- (void)onButImage:(id)sender {
    NSInteger nIndex = ((UIButton*)sender).tag;
    NotificationData *nData = [self getNotificationAtIndex:nIndex];
    
    switch (nData.type) {
        case NOTIFICATION_COMMENT:
        case NOTIFICATION_FAVOURITE:
        case NOTIFICATION_FOLLOW:
        case NOTIFICATION_MENTION:
        case NOTIFICATION_RATE: {
            mUserSelected = nData.user;
            mUsernameSelected = nData.username;
            
            [self gotoProfile];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getNotificationCount];
}

- (UITableViewCell *)configureCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forHeight:(BOOL)bForHeight {
    UITableViewCell *cell;
    
    NotificationData *nData = [self getNotificationAtIndex:indexPath.row];
    
    if (nData) {
        NotificationCell *notifyCell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"NotifyCellID"];
        [notifyCell fillContent:nData];
        
        if (!bForHeight) {
            [notifyCell.mButImg addTarget:self action:@selector(onButImage:) forControlEvents:UIControlEventTouchUpInside];
            notifyCell.mButImg.tag = indexPath.row;
        }
        
        cell = notifyCell;
    }
    else {
        NotificationCommentCell *commentCell = (NotificationCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"NotifyCommentCellID"];
        [commentCell fillContent:mPrevNotify forHeight:bForHeight];
        
        cell = commentCell;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:NO];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger nHeight = 57;
    NotificationData *nData = [self getNotificationAtIndex:indexPath.row];
    
    if (!nData) {
        NotificationCommentCell *commentCell = (NotificationCommentCell *)[self configureCell:tableView cellForRowAtIndexPath:indexPath forHeight:YES];
        nHeight = commentCell.mfHeight;
    }
    
    return nHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NotificationData *nData = [self getNotificationAtIndex:indexPath.row];
    
    if (!nData) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        mItemSelected = mPrevNotify.item;
        if (!mItemSelected) {
            [self alertForDelete];
            return;
        }
        
        [self performSegueWithIdentifier:@"Notify2Detail" sender:nil];
        
        return;
    }
    
    if (nData.type == NOTIFICATION_COMMENT) {
        NSArray *aryIndexPath = [[NSArray alloc] initWithObjects:
                                 [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0],
                                 nil];
        
        [tableView beginUpdates];
        
        if (nData.mbExpanded) {
            nData.mbExpanded = NO;
            [tableView deleteRowsAtIndexPaths:aryIndexPath
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            nData.mbExpanded = YES;
            [tableView insertRowsAtIndexPaths:aryIndexPath
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [tableView endUpdates];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (nData.type == NOTIFICATION_FOLLOW) {
            mUserSelected = nData.user;
            mUsernameSelected = nData.username;
            [self gotoProfile];
        }
        else if (nData.type == NOTIFICATION_RATE) {
            UserData *currentUser = [UserData currentUser];
            
            mUserSelected = currentUser;
            mUsernameSelected = [currentUser getUsernameToShow];
            [self performSegueWithIdentifier:@"Notify2Review" sender:nil];
        }
        else {
            mItemSelected = nData.item;
            if (!mItemSelected) {
                [self alertForDelete];
                return;
            }
            
            [self performSegueWithIdentifier:@"Notify2Detail" sender:nil];
        }
    }
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
        [self getNotification:nil];
    }
    
    return view;
}



@end
