//
//  FilterViewController.m
//  Deeds
//
//  Created by highjump on 15-4-10.
//
//

#import "FilterViewController.h"
#import "SWRevealViewController.h"
#import "MainViewController.h"
#import "MainTabbarController.h"

#import "CommonUtils.h"

#import "CategoryData.h"


@interface FilterViewController () {
    CategoryData *mCategorySelected;
}

@property (weak, nonatomic) IBOutlet UIButton *mButUpdate;
@property (weak, nonatomic) IBOutlet UISlider *mSliderDist;
@property (weak, nonatomic) IBOutlet UILabel *mLblDist;

@property (weak, nonatomic) IBOutlet UISwitch *mSwitchDeed;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitchNeed;
//@property (weak, nonatomic) IBOutlet UISwitch *mSwitchFollow;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mButUpdate.layer setMasksToBounds:YES];
    [self.mButUpdate.layer setCornerRadius:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    mCategorySelected = utils.mCategorySelected;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSliderChanged:(id)sender {
    [self.mLblDist setText:[NSString stringWithFormat:@"%d KM", (int)self.mSliderDist.value]];
}

- (IBAction)onButUpdate:(id)sender {
    
    CommonUtils *utils = [CommonUtils sharedObject];
    utils.mbFilterDeed = self.mSwitchDeed.on;
    utils.mbFilterNeed = self.mSwitchNeed.on;
//    utils.mbFilterFollow = self.mSwitchFollow.on;
    utils.mfFilterDistance = self.mSliderDist.value;
    
    // category
    utils.mCategorySelected = mCategorySelected;

    
    // close side bar
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];

    
    MainTabbarController *tabbarController = (MainTabbarController *)[self.revealViewController frontViewController];
    MainViewController *mvc = (MainViewController *)[tabbarController selectedViewController];
    [mvc getBlogWithProgress:YES needRefresh:YES];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CommonUtils *utils = [CommonUtils sharedObject];
    
    return [utils.maryCategory count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCategoryCellID"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"All"];
        
        if (!mCategorySelected) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else {
        CommonUtils *utils = [CommonUtils sharedObject];
        CategoryData *cData = [utils.maryCategory objectAtIndex:indexPath.row - 1];
        [cell.textLabel setText:cData.name];
        
        if ([mCategorySelected.objectId isEqualToString:cData.objectId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    if (indexPath.row == 0) {
        mCategorySelected = nil;
    }
    else {
        CategoryData *cData = [utils.maryCategory objectAtIndex:indexPath.row - 1];
        mCategorySelected = cData;
    }
    
    [tableView reloadData];
}



@end
