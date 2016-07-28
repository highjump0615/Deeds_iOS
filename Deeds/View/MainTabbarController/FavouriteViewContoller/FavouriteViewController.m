//
//  FavouriteViewController.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "FavouriteViewController.h"
#import "MainTabbarController.h"
#import "ProfileViewController.h"
#import "DetailViewController.h"

#import "FavouriteCell.h"

#import "ItemData.h"
#import "UserData.h"

@interface FavouriteViewController () {
    ItemData *mItemSelected;
    
    NSMutableArray *maryItem;
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UITextField *mTxtSearch;

@end

@implementation FavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    maryItem = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self onButSearch:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"Favourite2Profile"]) {
        ProfileViewController *viewController = [segue destinationViewController];
        viewController.mUser = mItemSelected.user;
        viewController.mUsername = mItemSelected.username;
    }
    else if ([[segue identifier] isEqualToString:@"Favourite2Detail"]) {
        DetailViewController *viewController = [segue destinationViewController];
        viewController.mItem = mItemSelected;
    }
}


#pragma mark - 

- (void)reloadTable {
    [self.mTableView reloadData];
}


-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)onButSearch:(id)sender {
    [self dismissKeyboard:nil];
    
    UserData *currentUser = [UserData currentUser];
    [maryItem removeAllObjects];
    
    // get items with search keyword
    for (ItemData *iData in currentUser.maryFavouriteItem) {
        if ([self.mTxtSearch.text length] == 0) {
            [maryItem addObject:iData];
            continue;
        }
        
        if ([iData.title containsString:self.mTxtSearch.text]) {
            [maryItem addObject:iData];
        }
    }
    
    [self reloadTable];
}

- (void)onButUser:(id)sender {
    NSInteger nIndex = ((UIButton*)sender).tag;
    mItemSelected = [self getItem:nIndex];
    
    UserData *currentUser = [UserData currentUser];
    if ([currentUser.objectId isEqualToString:mItemSelected.user.objectId]) {
        return;
    }
    
    [self performSegueWithIdentifier:@"Favourite2Profile" sender:nil];
}

- (NSInteger)getItemCount {
    NSInteger nCount = 0;
    
    nCount = [maryItem count];
    
    return nCount;
}

- (ItemData *)getItem:(NSInteger)index {
    ItemData *item;
    
    item = [maryItem objectAtIndex:index];
    
    return item;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getItemCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    FavouriteCell *favouriteCell = [tableView dequeueReusableCellWithIdentifier:@"FavouriteCellID"];
    
    ItemData *item = [self getItem:indexPath.row];
    [favouriteCell fillContent:item];
    
    [favouriteCell.mButUserPhoto addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
    favouriteCell.mButUserPhoto.tag = indexPath.row;
    [favouriteCell.mButUser addTarget:self action:@selector(onButUser:) forControlEvents:UIControlEventTouchUpInside];
    favouriteCell.mButUser.tag = indexPath.row;
    
    cell = favouriteCell;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    mItemSelected = [self getItem:indexPath.row];
    
    [self performSegueWithIdentifier:@"Favourite2Detail" sender:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // remove cell
        NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:deleteIndexPaths
                         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        UserData *currentUser = [UserData currentUser];
        ItemData *item = [self getItem:indexPath.row];
        
        [maryItem removeObjectAtIndex:indexPath.row];
        
        [currentUser.favourite removeObject:item];
        [currentUser saveInBackground];
        
        [currentUser.maryFavouriteItem removeObject:item];
        
        [tableView endUpdates];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissKeyboard:nil];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onButSearch:nil];
    return YES;
}



@end
