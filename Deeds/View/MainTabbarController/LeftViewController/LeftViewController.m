//
//  LeftViewController.m
//  Deeds
//
//  Created by highjump on 15-5-20.
//
//

#import "LeftViewController.h"
#import "ProfileViewController.h"
#import "SWRevealViewController.h"

#import "CommonUtils.h"

#import "GeneralData.h"
#import "UserData.h"

#import "FollowUserCell.h"
#import "LoadingView.h"


@interface LeftViewController () <UIGestureRecognizerDelegate> {
    UIRefreshControl *mRefreshControl;
    
    NSMutableArray *maryUser;
    NSInteger mnCountOnce;
    NSInteger mnCurrentCount;
    BOOL mbNeedMore;
    
    UserData *mUserSelected;
    UITapGestureRecognizer *mTap;
}

@property (weak, nonatomic) IBOutlet UILabel *mLblDeedNum;
@property (weak, nonatomic) IBOutlet UILabel *mLblDoneNum;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UITextField *mTxtSearch;

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    maryUser = [[NSMutableArray alloc] init];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl addTarget:self action:@selector(searchUser:) forControlEvents:UIControlEventValueChanged];
    [self.mTableView addSubview:mRefreshControl];
    
    // init
    mnCurrentCount = 0;
    mnCountOnce = 12;
    mbNeedMore = NO;
    
    mTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                   action:@selector(dismissKeyboard:)];
    [mTap setDelegate:self];
    
//    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.revealViewController.view addGestureRecognizer:mTap];
    
    [self setItemText];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    PFQuery *query = [GeneralData query];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            GeneralData *data = (GeneralData *)object;
            utils.mnItemcount = [data.itemcount integerValue];
            utils.mnItemdone = [data.itemdone integerValue];
            
            [self setItemText];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.revealViewController.view removeGestureRecognizer:mTap];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)setItemText {
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mLblDeedNum setText:[NSString stringWithFormat:@"%ld", utils.mnItemcount]];
    [self.mLblDoneNum setText:[NSString stringWithFormat:@"%ld", utils.mnItemdone]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Left2Profile"]) {
        ProfileViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mUserSelected;
        viewController.mUsername = [mUserSelected getUsernameToShow];
    }
}

#pragma mark -

- (void)searchUser:(UIRefreshControl *)sender {
    
    if (sender) { // refreshing
        [maryUser removeAllObjects];
        mnCurrentCount = 0;
    }
    
    PFQuery *query = [UserData query];
    [query whereKey:@"fullname" matchesRegex:self.mTxtSearch.text modifiers:@"i"];
    
    query.skip = mnCurrentCount;
    query.limit = mnCountOnce;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopRefresh];
        
        if (!error) {
            if ([objects count] > 0) {
                mbNeedMore = ([objects count] == mnCountOnce);
                
                for (UserData *uData in objects) {
                    [maryUser addObject:uData];
                }
            }
            else {
                mbNeedMore = NO;
            }
            
            mnCurrentCount = [maryUser count];
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


- (IBAction)onButSearch:(id)sender {
    [self dismissKeyboard:nil];
    
    if ([self.mTxtSearch.text length] == 0) {
        return;
    }
    
    [maryUser removeAllObjects];
    mnCurrentCount = 0;
    
    if (![mRefreshControl isRefreshing]) {
        [mRefreshControl beginRefreshing];
        
        CGPoint ptOffset = self.mTableView.contentOffset;
        [self.mTableView setContentOffset:CGPointMake(0, ptOffset.y - mRefreshControl.frame.size.height)
                                 animated:YES];
    }
    
    [self searchUser:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger nCount = [maryUser count];
    
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FollowUserCell *followCell = (FollowUserCell *)[tableView dequeueReusableCellWithIdentifier:@"LeftUserCellID"];
    UserData *uData = [maryUser objectAtIndex:indexPath.row];
    
    [followCell fillContent:uData];
    
    return followCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    mUserSelected = [maryUser objectAtIndex:indexPath.row];
    
    UserData *currentUser = [UserData currentUser];
    if ([mUserSelected.objectId isEqualToString:currentUser.objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Left2Profile" sender:nil];
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
        [self searchUser:nil];
    }
    
    return view;
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onButSearch:nil];
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    CGPoint pt = [touch locationInView:self.view];
//    if (CGRectContainsPoint(self.mTableView.frame, pt)) {
        [self dismissKeyboard:nil];
        return NO;
//    }
//    
//    return YES;
}


@end
