//
//  HomeItemCell.m
//  Deeds
//
//  Created by highjump on 15-4-11.
//
//

#import "HomeItemCell.h"

#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

#import "CommonUtils.h"

#import "ItemData.h"
#import "UserData.h"

@interface HomeItemCell() {
    ItemData *mItemData;
}

@property (weak, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewItem;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewDone;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewType;
@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblAddress;
@property (weak, nonatomic) IBOutlet UILabel *mLblDistance;
@property (weak, nonatomic) IBOutlet UILabel *mLblDate;

@property (weak, nonatomic) IBOutlet UIView *mViewDot;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewFavourite;

@end

@implementation HomeItemCell

- (void)awakeFromNib
{
    [self.mImgViewItem.layer setMasksToBounds:YES];
}

- (void)fillContent:(ItemData *)data {
    
    // user info
    UserData *user = data.user;
    PFFile *filePhoto = user.photo;
    
    [self.mButUserPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"user_default.png"]];
    [self.mButUser setTitle:[user getUsernameToShow] forState:UIControlStateNormal];
    
    // item info
    filePhoto = [data.images objectAtIndex:0];
    [self.mImgViewItem sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                         placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    [self.mLblTitle setText:data.title];
    
    if ([data.done boolValue]) {
        [self.mImgViewDone setHidden:NO];
    }
    else {
        [self.mImgViewDone setHidden:YES];
    }
    
    if (data.type == ITEMTYPE_DEED) {
        [self.mImgViewType setImage:[UIImage imageNamed:@"deed_tag.png"]];
    }
    else {
        [self.mImgViewType setImage:[UIImage imageNamed:@"need_tag.png"]];
    }
    
    // address
    NSString *strAddress = data.address;
    if (!strAddress || [strAddress length] == 0) {
        strAddress = @"Unknown Location";
    }
    [self.mLblAddress setText:strAddress];
    
    // date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"MMMM dd yyyy"];
    NSString *strDate = [dateFormat stringFromDate:data.createdAt];
    
    [self.mLblDate setText:strDate];
    
    // distance
    CommonUtils *utils = [CommonUtils sharedObject];
    CGFloat fDist = [utils getDistanceFromPoint:data.location];
    
    if (fDist < 0) {
        [self.mLblDistance setText:@"Unknown"];
    }
    else {
        [self.mLblDistance setText:[NSString stringWithFormat:@"%.0fKM Away", fDist]];
    }
    
    // favourite
    UserData *currentUser = [UserData currentUser];
    [self.mImgViewFavourite setHidden:![currentUser isItemFavourite:data]];
    
    mItemData = data;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // view dot
    double dRadius = self.mViewDot.frame.size.height / 2;
    [self.mViewDot.layer setMasksToBounds:YES];
    [self.mViewDot.layer setCornerRadius:dRadius];
    
    // user photo
    dRadius = self.mButUserPhoto.frame.size.height / 2;
    [self.mButUserPhoto.layer setMasksToBounds:YES];
    [self.mButUserPhoto.layer setCornerRadius:dRadius];
    
    // shadow on view
    CGRect rtShadow = self.bounds;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:rtShadow];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.3f;
    self.layer.shadowPath = shadowPath.CGPath;
    
    // set the radius
    CGFloat radius = 3.0;
    // set the mask frame, and increase the height by the
    // corner radius to hide bottom corners
    CGRect maskFrame = self.bounds;
//    maskFrame.size.height += radius;
    // create the mask layer
    CALayer *maskLayer = [CALayer layer];
    maskLayer.cornerRadius = radius;
    maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskLayer.frame = maskFrame;
    
    // set the mask
    self.mView.layer.mask = maskLayer;
}

@end
