//
//  MainViewController.m
//  Deeds
//
//  Created by highjump on 15-4-7.
//
//

#import "MainViewController.h"
#import "MainTabbarController.h"
#import "ProfileViewController.h"
#import "DetailViewController.h"

#import "HomeItemCell.h"
#import "NavigationBarView.h"
#import "LoadingView.h"

#import "CommonUtils.h"
#import "UserData.h"
#import "ItemData.h"

typedef enum {
    QUERY_LAST = 0,
    QUERY_NEAR
} QueryType;


@interface MainViewController () {
    UIRefreshControl *mRefreshControl;
    QueryType mnQueryType;
    
    ItemData *mItemSelected;
    
    NSInteger mnCountOnce;
    NSInteger mnCurrentCount;
    BOOL mbNeedMore;
    
    NSMutableArray *maryBlog;
    
    BOOL mbLoaded;
    PFQuery *mQueryOld;
}

@property (weak, nonatomic) IBOutlet UICollectionView *mCollectionView;
@property (weak, nonatomic) IBOutlet NavigationBarView *mViewNavBar;
@property (weak, nonatomic) IBOutlet UIView *mViewHeader;

@property (weak, nonatomic) IBOutlet UIButton *mButLast;
@property (weak, nonatomic) IBOutlet UIButton *mButNear;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstUnderline;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstHeader;

@property (weak, nonatomic) IBOutlet UITextField *mTxtSearch;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mCollectionView setAlwaysBounceVertical:YES];
    
    // Pull to refresh
    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl addTarget:self action:@selector(getBlog:) forControlEvents:UIControlEventValueChanged];
    [self.mCollectionView addSubview:mRefreshControl];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard:)];
//    [self.view addGestureRecognizer:tap];
    
    mnQueryType = QUERY_LAST;
    
    
    // init
    mnCurrentCount = 0;
    mnCountOnce = 6;
    mbNeedMore = NO;
    mbLoaded = NO;
    
    maryBlog = [[NSMutableArray alloc] init];
    
    [self.mCollectionView registerClass:[UICollectionReusableView class]
             forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                    withReuseIdentifier:@"LoadingFooter"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews {
    UIEdgeInsets edgeTable = self.mCollectionView.contentInset;
    edgeTable.top = self.mViewHeader.frame.size.height;
    [self.mCollectionView setContentInset:edgeTable];
    [self.mCollectionView setScrollIndicatorInsets:edgeTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (mbLoaded) {
        [self reloadTable];
        return;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (mQueryOld) {
        NSLog(@"%s, %d", __PRETTY_FUNCTION__, [mRefreshControl isRefreshing] );
        
        [mRefreshControl beginRefreshing];
        
        CGPoint ptOffset = self.mCollectionView.contentOffset;
        [self.mCollectionView setContentOffset:CGPointMake(0, ptOffset.y - mRefreshControl.frame.size.height)
                                      animated:YES];
    }
    
    if (mbLoaded) {
        return;
    }
    
    // get item
    [self getBlogWithProgress:YES needRefresh:NO];
    mbLoaded = YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Main2Profile"]) {
        ProfileViewController *viewController =  [segue destinationViewController];
        viewController.mUser = mItemSelected.user;
        viewController.mUsername = mItemSelected.username;
    }
    else if ([[segue identifier] isEqualToString:@"Main2Detail"]) {
        DetailViewController *viewController =  [segue destinationViewController];
        viewController.mItem = mItemSelected;
    }
}

#pragma mark -

- (void)reloadTable {
//    [self.mCollectionView performBatchUpdates:^{
//        [self.mCollectionView reloadData];
//    } completion:^(BOOL finished) {}];
    
    [self.mCollectionView performBatchUpdates:^{
        [self.mCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:nil];
    
//    [self.mCollectionView reloadData];
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)setQueryType:(QueryType)type {
    [self dismissKeyboard:nil];
    
    if (type == mnQueryType) {
        return;
    }
    
    mnQueryType = type;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.mCstUnderline setConstant:mnQueryType * screenWidth / 2];
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self getBlogWithProgress:YES needRefresh:YES];
                     }];
}

- (IBAction)onButLast:(id)sender {
    [self setQueryType:QUERY_LAST];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mButLast setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
    [self.mButNear setTitleColor:utils.mColorGray forState:UIControlStateNormal];
}

- (IBAction)onButNear:(id)sender {
    [self setQueryType:QUERY_NEAR];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mButLast setTitleColor:utils.mColorGray forState:UIControlStateNormal];
    [self.mButNear setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
}

- (IBAction)onButFilter:(id)sender {
    MainTabbarController *tabbarController = (MainTabbarController *)[self tabBarController];
    [tabbarController revealRightSidebar:sender];
}

- (IBAction)onButMenu:(id)sender {
    MainTabbarController *tabbarController = (MainTabbarController *)[self tabBarController];
    [tabbarController revealLeftSidebar:sender];
}

- (void)getBlogWithProgress:(BOOL)animation needRefresh:(BOOL)bRefresh {
    
    if (mQueryOld) {
        [mQueryOld cancel];
        mQueryOld = nil;
        
        [self stopRefresh];
    }

    if ([self.mCollectionView numberOfItemsInSection:0] > 0) {
        [self.mCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UICollectionViewScrollPositionTop
                                      animated:NO];
    }
    
    if (animation) {
        if (![mRefreshControl isRefreshing]) {
            [mRefreshControl beginRefreshing];
            
            CGPoint ptOffset = self.mCollectionView.contentOffset;
            [self.mCollectionView setContentOffset:CGPointMake(0, ptOffset.y - mRefreshControl.frame.size.height)
                                          animated:YES];
        }
    }
    
    if (bRefresh) {
        [self getBlog:mRefreshControl];
    }
    else {
        [self getBlog:nil];
    }
}

- (void)getBlog:(UIRefreshControl *)sender {
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (sender) { // refreshing
        mnCurrentCount = 0;
    }
    
    mbNeedMore = NO;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    UserData *currentUser = [UserData currentUser];
    
    // get blog data
    PFQuery *query = [ItemData query];
    if ([self.mTxtSearch.text length] > 0) {
        
        PFQuery *titleQuery = [ItemData query];
        [titleQuery whereKey:@"title" matchesRegex:self.mTxtSearch.text modifiers:@"i"];
        
        PFQuery *addressQuery = [ItemData query];
        [addressQuery whereKey:@"address" matchesRegex:self.mTxtSearch.text modifiers:@"i"];
        
        query = [PFQuery orQueryWithSubqueries:@[titleQuery, addressQuery]];
        
        //        [query whereKey:@"title" matchesRegex:self.mTxtSearch.text modifiers:@"i"];
    }

    [query includeKey:@"user"];
    
    if (!utils.mbFilterDeed && !utils.mbFilterNeed) {
        [maryBlog removeAllObjects];
        mnCurrentCount = 0;
        
        [self reloadTable];
        
        [self stopRefresh];

        
        return;
    }
    else if (utils.mbFilterDeed && !utils.mbFilterNeed) {
        [query whereKey:@"type" equalTo:@(ITEMTYPE_DEED)];
    }
    else if (!utils.mbFilterDeed && utils.mbFilterNeed) {
        [query whereKey:@"type" equalTo:@(ITEMTYPE_INNEED)];
    }
    
    if (utils.mCategorySelected) {
        [query whereKey:@"category" equalTo:utils.mCategorySelected];
    }
    
    if (utils.mbFilterFollow) {
        [query whereKey:@"user" containedIn:currentUser.maryFollowingUser];
    }

    if (mnQueryType == QUERY_LAST) {
        [query orderByDescending:@"createdAt"];
    }
    else {
        PFGeoPoint *point;
        
        if (utils.mLocationCurrent) {
            // Query for posts sort of kind of near our current location.
            point = [PFGeoPoint geoPointWithLatitude:utils.mLocationCurrent.coordinate.latitude
                                           longitude:utils.mLocationCurrent.coordinate.longitude];
        }
        else {
            point = currentUser.location;
        }
        
        [query whereKey:@"location" nearGeoPoint:point withinKilometers:utils.mfFilterDistance];
    }
    
    query.skip = mnCurrentCount;
    query.limit = mnCountOnce;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self stopRefresh];
        
        if (!error) {
            
            if (sender) { // refreshing
                [maryBlog removeAllObjects];
            }
            
            if ([objects count] > 0) {
                mbNeedMore = ([objects count] == mnCountOnce);
                
                for (ItemData *iData in objects) {
                    [maryBlog addObject:iData];
                }
            }
            else {
                mbNeedMore = NO;
            }
            
            mnCurrentCount = [maryBlog count];
            [self reloadTable];
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error localizedDescription]);
        }
    }];
    
    mQueryOld = query;
}

- (void)stopRefresh {
    mQueryOld = nil;
    [mRefreshControl endRefreshing];
}

- (IBAction)onButSearch:(id)sender {
    [self dismissKeyboard:nil];
    
    [self performSelector:@selector(searchBlog:) withObject:nil afterDelay:0.4];
}

- (void)searchBlog:(id)sender {
    [self getBlogWithProgress:YES needRefresh:YES];
}


- (void)onButUser:(id)sender {
    NSInteger nIndex = ((UIButton*)sender).tag;
    mItemSelected = [maryBlog objectAtIndex:nIndex];
    
    UserData *currentUser = [UserData currentUser];
    if ([currentUser.objectId isEqualToString:mItemSelected.user.objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Main2Profile" sender:nil];
}


# pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [maryBlog count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"HomeItemCellID";
    
    HomeItemCell *cell = (HomeItemCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    ItemData *item = [maryBlog objectAtIndex:indexPath.row];
    [cell fillContent:item];
    
    [cell.mButUserPhoto addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
    cell.mButUserPhoto.tag = indexPath.row;
    [cell.mButUser addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
    cell.mButUser.tag = indexPath.row;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat fWidth = (screenWidth - 24) / 2;
    
    return CGSizeMake(fWidth, 182);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    mItemSelected = [maryBlog objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"Main2Detail" sender:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    if (mbNeedMore) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 50);
    }
    
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:@"LoadingFooter"
                                                                                   forIndexPath:indexPath];
        if (reusableView.tag != 101) {
            UIView *view = [LoadingView loadingView:screenWidth];
            NSLog(@"%f, %f", view.frame.size.width, view.frame.size.height);
            
            [reusableView addSubview:view];
            
            reusableView.tag = 101;
        }
        
        NSLog(@"%s --- %ld", __PRETTY_FUNCTION__, (long)indexPath.row);
        
        if (mbNeedMore) {
            [self getBlog:nil];
        }
        
        return reusableView;
    }
    
    return nil;
}

- (void)setHeaderPos:(CGFloat)fPos {
    if ([self.mCstHeader constant] == fPos) {
        return;
    }
    
    [self.mCstHeader setConstant:fPos];
    [self.view layoutIfNeeded];
    
//    CGRect rt =  self.mViewHeader.frame;
//    if (rt.origin.y == fPos + self.mViewNavBar.frame.size.height) {
//        return;
//    }
//    
//    rt.origin.y = fPos + self.mViewNavBar.frame.size.height;
//    [self.mViewHeader setFrame:rt];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissKeyboard:nil];
    
    CGFloat fDiff = scrollView.contentOffset.y - (-self.mViewHeader.frame.size.height);
    
    if (fDiff > self.mViewHeader.frame.size.height) {
        [self setHeaderPos:-self.mViewHeader.frame.size.height];
    }
    else if (fDiff > 0) {
        [self setHeaderPos:-fDiff];
    }
    else {
        [self setHeaderPos:0];
    }

//    NSLog(@"scroll %f, diff:%f", scrollView.contentOffset.y, fDiff);
}


#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    MainTabbarController *tabbarController = (MainTabbarController *)[self tabBarController];
    [tabbarController closeSidebar];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onButSearch:nil];
    return YES;
}

@end
