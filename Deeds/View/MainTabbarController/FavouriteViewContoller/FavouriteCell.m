//
//  FavouriteCell.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "FavouriteCell.h"

#import "ItemData.h"
#import "UserData.h"

#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

#import "CommonUtils.h"



@interface FavouriteCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewItem;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewDone;

@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblDistance;
@property (weak, nonatomic) IBOutlet UILabel *mLblDate;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewType;
@property (weak, nonatomic) IBOutlet UIView *mViewDot;

@end

@implementation FavouriteCell

- (void)awakeFromNib {
    // Initialization code
    [self.mImgViewItem.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(ItemData *)data {
    // user info
    UserData *user = data.user;
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *filePhoto = user.photo;
        
        [self.mButUserPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                      forState:UIControlStateNormal
                              placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        [self.mButUser setTitle:[user getUsernameToShow] forState:UIControlStateNormal];
    }];
    [self.mButUser setTitle:data.username forState:UIControlStateNormal];
    
    // item info
    PFFile *fileImg = [data.images objectAtIndex:0];
    [self.mImgViewItem sd_setImageWithURL:[NSURL URLWithString:fileImg.url]
                         placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    [self.mLblTitle setText:data.title];
    
    // done mark
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
}

@end
