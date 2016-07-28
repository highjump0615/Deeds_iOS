//
//  AddItemViewController.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "AddItemViewController.h"

#import "AddTitleCell.h"
#import "AddDescriptionCell.h"
#import "AddImageCell.h"
#import "AddCheckinCell.h"
#import "AddCategoryCell.h"

#import "PlaceholderTextView.h"
#import "MBProgressHUD.h"
#import "FullImageView.h"
#import "ActionSheetCustomPicker.h"

#import "CommonUtils.h"
#import "CommonDefine.h"

#import "ItemData.h"
#import "UserData.h"
#import "GeneralData.h"
#import "CategoryData.h"

#import "SDWebImageManager.h"

#import <MobileCoreServices/MobileCoreServices.h>


@interface AddItemViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddImageCellDelegate, ActionSheetCustomPickerDelegate> {
    ItemType mnType;
    UIImagePickerController *mImagePicker;
    
    UIView *mTxtCurrent;
    BOOL mbIsViewPushed;
    int mnPushedHeight;
    CGSize mszKeyboard;
    
    NSString *mstrTitle;
    NSString *mstrDesc;
    NSString *mstrAddress;
    NSMutableArray *maryImgItem;
    
    MBProgressHUD *mHud;
    
    NSInteger mnLoadedImgCount;
    BOOL mbImageModified;
    
    UIAlertView *mAlertDelete;
    UIAlertView *mAlertAddress;
    UIAlertView *mAlertDone;
    
    // actionsheet picker
    NSInteger mnSelectedIndex;
    NSInteger mnSelectingIndex;
}

@property (weak, nonatomic) IBOutlet UIButton *mButBack;
@property (weak, nonatomic) IBOutlet UILabel *mLblNavBarTitle;

@property (weak, nonatomic) IBOutlet UIButton *mButDeed;
@property (weak, nonatomic) IBOutlet UIButton *mButInNeed;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewArrow;

@property (weak, nonatomic) IBOutlet UIView *mViewButton;
@property (weak, nonatomic) IBOutlet UIButton *mButSavePublish;

@property (weak, nonatomic) IBOutlet UIView *mViewDelete;
@property (weak, nonatomic) IBOutlet UIButton *mButDelete;
@property (weak, nonatomic) IBOutlet UIButton *mButSave;
@property (weak, nonatomic) IBOutlet UIButton *mButDone;

@property (weak, nonatomic) IBOutlet UITableView *mTableView;

@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mButSavePublish.layer setMasksToBounds:YES];
    [self.mButSavePublish.layer setCornerRadius:3];
    
    [self.mButDelete.layer setMasksToBounds:YES];
    [self.mButDelete.layer setCornerRadius:3];
    
    [self.mButSave.layer setMasksToBounds:YES];
    [self.mButSave.layer setCornerRadius:3];
    
    [self.mButDone.layer setMasksToBounds:YES];
    [self.mButDone.layer setCornerRadius:3];
    
    mnType = ITEMTYPE_DEED;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    
    // keybaord
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    maryImgItem = [[NSMutableArray alloc] init];
    
    mnSelectedIndex = -1;
    
    if (self.mItem) {
        [self.mButBack setHidden:NO];
        [self.mLblNavBarTitle setText:@"Edit Post"];
        [self.mViewButton setHidden:YES];
        [self.mViewDelete setHidden:NO];
        
        mnType = self.mItem.type;
        mstrTitle = self.mItem.title;
        mstrDesc = self.mItem.desc;
    
        for (int i = 0; i < IMAGE_ITEM_COUNT; i++) {
            UIImage *image = [[UIImage alloc] init];
            [maryImgItem addObject:image];
        }
        
        [self setCategoryIndex];
    }
    else {
        [self.mButBack setHidden:YES];
        [self.mLblNavBarTitle setText:@"Add Post"];
        [self.mViewButton setHidden:NO];
        [self.mViewDelete setHidden:YES];
    }
    
    [self updateSegments:mnType];
    
    mnLoadedImgCount = 0;
    mbImageModified = NO;
}

- (void)setCategoryIndex {
    CommonUtils *utils = [CommonUtils sharedObject];
    for (int i = 0; i < [utils.maryCategory count]; i++) {
        CategoryData *cData = [utils.maryCategory objectAtIndex:i];
        if ([cData.objectId isEqualToString:self.mItem.category.objectId]) {
            mnSelectedIndex = i;
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    // shadow on view
    CGRect rtShadow = self.mViewButton.bounds;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
    self.mViewButton.layer.masksToBounds = NO;
    self.mViewButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mViewButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.mViewButton.layer.shadowOpacity = 0.2f;
    self.mViewButton.layer.shadowPath = shadowPath.CGPath;
    
    rtShadow = self.mViewDelete.bounds;
    shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
    self.mViewDelete.layer.masksToBounds = NO;
    self.mViewDelete.layer.shadowColor = [UIColor blackColor].CGColor;
    self.mViewDelete.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.mViewDelete.layer.shadowOpacity = 0.2f;
    self.mViewDelete.layer.shadowPath = shadowPath.CGPath;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(UITapGestureRecognizer *) sender {
    [self.view endEditing:YES];
}

- (void)updateSegments:(int)type {
    
    mnType = type;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    if (mnType == ITEMTYPE_DEED) {
        // deed active
        UIImage* image = [UIImage imageNamed:@"add_deed_active_but_bg.png"];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 42, 0, 0);
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        [self.mButDeed setBackgroundImage:image forState:UIControlStateNormal];
        [self.mButDeed setBackgroundImage:image forState:UIControlStateHighlighted];
        [self.mButDeed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        // indeed deactive
        image = [UIImage imageNamed:@"add_need_deactive_but_bg.png"];
        insets = UIEdgeInsetsMake(0, 0, 0, 42);
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        [self.mButInNeed setBackgroundImage:image forState:UIControlStateNormal];
        [self.mButInNeed setBackgroundImage:image forState:UIControlStateHighlighted];
        [self.mButInNeed setTitleColor:utils.mColorGray forState:UIControlStateNormal];
        
        [self.mImgViewArrow setImage:[UIImage imageNamed:@"add_deed_mark.png"]];
    }
    else {
        // deed deactive
        UIImage* image = [UIImage imageNamed:@"add_deed_deactive_but_bg.png"];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 42, 0, 0);
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        [self.mButDeed setBackgroundImage:image forState:UIControlStateNormal];
        [self.mButDeed setBackgroundImage:image forState:UIControlStateHighlighted];
        [self.mButDeed setTitleColor:utils.mColorGray forState:UIControlStateNormal];
        
        // indeed deactive
        image = [UIImage imageNamed:@"add_need_active_but_bg.png"];
        insets = UIEdgeInsetsMake(0, 0, 0, 42);
        image = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        
        [self.mButInNeed setBackgroundImage:image forState:UIControlStateNormal];
        [self.mButInNeed setBackgroundImage:image forState:UIControlStateHighlighted];
        [self.mButInNeed setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.mImgViewArrow setImage:[UIImage imageNamed:@"add_need_mark.png"]];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onButBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onButDeed:(id)sender {
    [self updateSegments:ITEMTYPE_DEED];
}

- (IBAction)onButInNeed:(id)sender {
    [self updateSegments:ITEMTYPE_INNEED];
}

- (void)onButTakePhoto:(id)sender {
    if ([maryImgItem count] >= IMAGE_ITEM_COUNT) {
        return;
    }
    
    [self shouldStartCameraController];
}

- (void)onButChoosePhoto:(id)sender {
    if ([maryImgItem count] >= IMAGE_ITEM_COUNT) {
        return;
    }
    
    [self shouldStartPhotoLibraryPickerController];
}

- (void)onButAddress:(id)sender {
    if (!mAlertAddress) {
        mAlertAddress = [[UIAlertView alloc]initWithTitle:@"Address"
                                                  message:@""
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:@"OK", nil];
        mAlertAddress.alertViewStyle = UIAlertViewStylePlainTextInput;
    }
    
    UITextField *textField = [mAlertAddress textFieldAtIndex:0];
    [textField setPlaceholder:@"Input your address here"];
    [textField setText:mstrAddress];
    
    [mAlertAddress show];
}

- (void)onButCategory:(id)sender {
    NSMutableArray *selectionArray = [[NSMutableArray alloc] init];
    [selectionArray addObject:[NSNumber numberWithInteger:MAX(mnSelectedIndex, 0)]];
    
    [ActionSheetCustomPicker showPickerWithTitle:@"Select Category"
                                        delegate:self
                                showCancelButton:YES
                                          origin:self.mTableView
                               initialSelections:selectionArray];
}

- (IBAction)onButDelete:(id)sender {
    if (!mAlertDelete) {
        mAlertDelete = [[UIAlertView alloc]initWithTitle:@"Are you sure to delete this item?"
                                                 message:@""
                                                delegate:self
                                       cancelButtonTitle:@"No"
                                       otherButtonTitles:@"Yes",nil];
    }
    
    [mAlertDelete show];
}

- (void)saveItem {
    if ([mstrTitle length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input the title"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([mstrDesc length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Input the description"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([maryImgItem count] < IMAGE_ITEM_COUNT) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You must have 3 pictures"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (mnSelectedIndex < 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You must select a category"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    ItemData *itemObject;
    
    if (self.mItem) {
        itemObject = self.mItem;
    }
    else {
        itemObject = [ItemData object];
    }
    
    mHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mHud.labelText = @"Uploading...";
    
    UserData *currentUser = [UserData currentUser];
    
    itemObject.user = currentUser;
    itemObject.username = [currentUser getUsernameToShow];
    itemObject.title = mstrTitle;
    itemObject.desc = mstrDesc;
    itemObject.type = mnType;
    itemObject.address = mstrAddress;
    itemObject.location = [PFGeoPoint geoPointWithLatitude:utils.mLocationCurrent.coordinate.latitude
                                                 longitude:utils.mLocationCurrent.coordinate.longitude];
    
    // category
    CategoryData *cData = [utils.maryCategory objectAtIndex:mnSelectedIndex];
    itemObject.category = cData;
    
    NSMutableArray *aryImgData = [[NSMutableArray alloc] init];
    
    if (mbImageModified) {
        
        [itemObject.images removeAllObjects];
        
        // images
        for (UIImage *image in maryImgItem) {
            UIImage *resizedImage = [CommonUtils imageWithImage:image scaledToWidth:320];
            // JPEG to decrease file size and enable faster uploads & downloads
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
            
            PFFile *fileImg = [PFFile fileWithName:@"image.jpg" data:imageData];
            
            if (self.mItem) {
                [itemObject.images addObject:fileImg];
            }
            else {
                [itemObject addObject:fileImg forKey:@"images"];
            }
            
            [aryImgData addObject:imageData];
        }
    }
    
    [itemObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [mHud removeFromSuperview];
        
        if (!error) {
            if (self.mItem) {
                [self onButBack:nil];
            }
            else {
                // clear data & UI
                mstrTitle = @"";
                mstrDesc = @"";
                mstrAddress = currentUser.address;
                [maryImgItem removeAllObjects];
                
                [self.mTableView reloadData];
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Your item has been successfully posted"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                // increase the count value
                PFQuery *query = [GeneralData query];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if (!error) {
                        [object incrementKey:@"itemcount"];
                        [object saveInBackground];
                    }
                }];
            }
            
            //
            // save to sd web image
            //
            if (!mbImageModified) {
                return;
            }
            
            for (int i = 0; i < [itemObject.images count]; i++) {
                PFFile *fileImg = [itemObject.images objectAtIndex:i];
                NSData *imgData = [aryImgData objectAtIndex:i];
                
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:fileImg.url]];
                UIImage *imgPost = [UIImage imageWithData:imgData];
                [[SDImageCache sharedImageCache] storeImage:imgPost forKey:key toDisk:YES];
            }
        }
        else {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[error userInfo][@"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (IBAction)onButSave:(id)sender {
    [self saveItem];
}

- (IBAction)onButSavePublish:(id)sender {
    [self saveItem];
}

- (IBAction)onButDone:(id)sender {
    if ([self.mItem.done boolValue]) {
        return;
    }
    
    if (!mAlertDone) {
        mAlertDone = [[UIAlertView alloc]initWithTitle:@"Are you sure to mark this item as solved?"
                                               message:@""
                                              delegate:self
                                     cancelButtonTitle:@"No"
                                     otherButtonTitles:@"Yes",nil];
    }
    [mAlertDone show];
}


#pragma mark - KeyBoard notifications

- (void)keyboardWillShow:(NSNotification*)notification {
    const float movementDuration = 0.3f; // Standard duration for iOS
    
    if (notification) {
        // Get the size of the keyboard.
        mszKeyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    }
    
    // Given size may not account for screen rotation
    float keyboardHeight = MIN(mszKeyboard.height,mszKeyboard.width);
    
    // Get the position of current TextField, so we know if it will be hidden by the keyboard
    CGPoint p = [mTxtCurrent.superview convertPoint:mTxtCurrent.frame.origin toView:self.view];
    
    // Self explanatory
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    int availableSpace = screenHeight - keyboardHeight;
    
//    NSLog(@"y: %f, screenHeight: %d", p.y, screenHeight);
    
    int fieldHeight = mTxtCurrent.frame.size.height;
    int fieldBelowSpace = 10;
    int neededSpace = p.y + fieldHeight + fieldBelowSpace;
    
//    NSLog(@"availableSpace: %d, neededSpace:%d", availableSpace, neededSpace);
    
    if (availableSpace < neededSpace) {
        
        if (mbIsViewPushed) {
            return;
        }
        
        int spaceToAdd = availableSpace-neededSpace;
        
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
        self.view.frame = CGRectOffset(self.view.frame, 0, -mnPushedHeight);
        [UIView commitAnimations];
    }
}


- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            mImagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.showsCameraControls = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    mImagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, (NSString *) kUTTypeMovie, nil];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        mImagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //        cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
        
    } else {
        return NO;
    }
    
    mImagePicker.allowsEditing = YES;
    mImagePicker.delegate = self;
    
    [self presentViewController:mImagePicker animated:YES completion:nil];
    
    return YES;
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *imgRes = [info objectForKey:UIImagePickerControllerEditedImage];
    [maryImgItem addObject:imgRes];
    [self.mTableView reloadData];
    
    mbImageModified = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0: {
            AddTitleCell *titleCell = (AddTitleCell *)[tableView dequeueReusableCellWithIdentifier:@"AddTitleCellID"];
            [titleCell.mTxtTitle setText:mstrTitle];
            
            cell = titleCell;
            break;
        }
            
        case 1: {
            AddDescriptionCell *descCell = (AddDescriptionCell *)[tableView dequeueReusableCellWithIdentifier:@"AddDescCellID"];
            [descCell.mTxtDesc setText:mstrDesc];
            
            cell = descCell;
            break;
        }
            
        case 2: {
            AddImageCell *imageCell = (AddImageCell *)[tableView dequeueReusableCellWithIdentifier:@"AddImageCellID"];
            [imageCell setDelegate:self];
            
            [imageCell.mButTakePhoto addTarget:self action:@selector(onButTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
            [imageCell.mButChoosePhoto addTarget:self action:@selector(onButChoosePhoto:) forControlEvents:UIControlEventTouchUpInside];
            
            if (self.mItem && mnLoadedImgCount < IMAGE_ITEM_COUNT) {
                [imageCell fillContent:self.mItem.images isImage:NO];
            }
            else {
                [imageCell fillContent:maryImgItem isImage:YES];
            }
            
            cell = imageCell;
            break;
        }
            
        case 3: {
            AddCheckinCell *checkinCell = (AddCheckinCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCheckinCellID"];
            [checkinCell.mButEdit addTarget:self action:@selector(onButAddress:) forControlEvents:UIControlEventTouchUpInside];
            
            if (mstrAddress && [mstrAddress length] > 0) {
                [checkinCell.mLblAddress setText:mstrAddress];
                [checkinCell.mLblAddress setEnabled:YES];
            }
            else {
                [checkinCell.mLblAddress setText:@"City or Address"];
                [checkinCell.mLblAddress setEnabled:NO];
            }
            
            cell = checkinCell;
            break;
        }
        case 4: {
            AddCategoryCell *categoryCell = (AddCategoryCell *)[tableView dequeueReusableCellWithIdentifier:@"AddCategoryCellID"];
            [categoryCell.mButEdit addTarget:self action:@selector(onButCategory:) forControlEvents:UIControlEventTouchUpInside];

            if (mnSelectedIndex >= 0) {
                CommonUtils *utils = [CommonUtils sharedObject];
                CategoryData *cData = [utils.maryCategory objectAtIndex:mnSelectedIndex];
                [categoryCell.mLblCategory setText:cData.name];
            }
            
            cell = categoryCell;
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    switch (indexPath.row) {
        case 0:
            height = 100;
            break;
            
        case 1:
//            height = 30;
            height += 103 / 320.0 * screenWidth;
            break;
            
        case 2:
            height = 130;
            break;
            
        case 3:
        case 4:
            height = 58;
            break;
            
        default:
            break;
    }
    
    return height;
}

#pragma mark - TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Get a reference to the currentField, so that we can dispose of using outlets.
    mTxtCurrent = textField;
    
    [self keyboardWillShow:nil];
}

// Reseting the view container if moved
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self restoreViewPos];
    
    mstrTitle = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}


#pragma mark - UITextViewDelegate

- (void)textViewShouldBeginEditing:(UITextView *)textView {
    mTxtCurrent = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self restoreViewPos];
    
    mstrDesc = textView.text;
}


#pragma mark - AddImageCellDelegate

- (void)onImageItem:(NSInteger)nIndex frame:(CGRect)rtFrame {
    if ([maryImgItem count] <= nIndex) {
        return;
    }
    
    FullImageView *fullView = (FullImageView *)[FullImageView initView:self.view];
    [fullView setItemImages:maryImgItem];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    CGRect rectInTableView = [self.mTableView rectForRowAtIndexPath:indexPath];
    CGRect rectInSuperview = [self.mTableView convertRect:rectInTableView toView:self.view];
    
    CGRect rtRealFrame = rtFrame;
    rtRealFrame.origin.y += rectInSuperview.origin.y;
    
    [fullView showView:rtRealFrame index:nIndex];
}

- (void)onRemoveItem:(NSInteger)nIndex {
    [maryImgItem removeObjectAtIndex:nIndex];
    [self.mTableView reloadData];
}

- (void)setItemImage:(UIImage *)image index:(NSInteger)nIndex {
    maryImgItem[nIndex] = image;

    mnLoadedImgCount++;
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (alertView == mAlertDelete) {
            [self.mItem deleteInBackground];
            [self onButBack:nil];
        }
        else if (alertView == mAlertAddress) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            mstrAddress = textField.text;
            [self.mTableView reloadData];
        }
        else if (alertView == mAlertDone) {
            self.mItem.done = @(YES);
            [self.mItem saveInBackground];
            
            // increase the count value
            PFQuery *query = [GeneralData query];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (!error) {
                    [object incrementKey:@"itemdone"];
                    [object saveInBackground];
                }
            }];
            
            [self onButBack:nil];
        }
    }
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - ActionSheetCustomPickerDelegate Optional's
/////////////////////////////////////////////////////////////////////////
- (void)configurePickerView:(UIPickerView *)pickerView
{
    // Override default and hide selection indicator
    pickerView.showsSelectionIndicator = YES;
}

- (void)actionSheetPickerDidSucceed:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
    mnSelectedIndex = MAX(mnSelectingIndex, 0);
    
    [self.mTableView reloadData];
}

- (void)actionSheetPickerDidCancel:(AbstractActionSheetPicker *)actionSheetPicker origin:(id)origin {
//    [self setCategoryIndex];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark - UIPickerViewDataSource Implementation
/////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    CommonUtils *utils = [CommonUtils sharedObject];
    
    return [utils.maryCategory count];
}

/////////////////////////////////////////////////////////////////////////
#pragma mark UIPickerViewDelegate Implementation
/////////////////////////////////////////////////////////////////////////

// these methods return either a plain UIString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    CommonUtils *utils = [CommonUtils sharedObject];
    CategoryData *cData = [utils.maryCategory objectAtIndex:row];
    
    return cData.name;
}

/////////////////////////////////////////////////////////////////////////

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    mnSelectingIndex = row;
}



@end
