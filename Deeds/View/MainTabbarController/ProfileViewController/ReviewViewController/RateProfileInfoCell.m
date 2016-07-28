//
//  RateProfileInfoCell.m
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import "RateProfileInfoCell.h"

#import "UserData.h"
#import "UIImageView+WebCache.h"

#import "CommonUtils.h"



@interface RateProfileInfoCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstTopMargin;
@property (weak, nonatomic) IBOutlet UIView *mViewPhotoBack;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblName;
@property (weak, nonatomic) IBOutlet UILabel *mLblDesc;
@property (weak, nonatomic) IBOutlet UIButton *mButReviewNum;

@end

@implementation RateProfileInfoCell

- (void)awakeFromNib {
    // Initialization code
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    [self.mButReviewNum.layer setBorderWidth:1.0f];
    [self.mButReviewNum.layer setBorderColor:utils.mColorYellow.CGColor];
    double dRadius = self.mButReviewNum.frame.size.height / 2;
    [self.mButReviewNum.layer setMasksToBounds:YES];
    [self.mButReviewNum.layer setCornerRadius:dRadius];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)data username:(NSString *)username {
    // show photo
    if (data.createdAt) {
        PFFile *filePhoto = data.photo;
        [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                              placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        
        [self.mLblName setText:[data getUsernameToShow]];
        
        // member since
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:data.createdAt]; // Get necessary date components
        NSInteger nYear = [components year];
        
        NSMutableString *strDesc = [NSMutableString stringWithString:@""];
        [strDesc appendFormat:@"Member Since: %ld", (long)nYear];
        
        if (data.address && [data.address length] > 0) {
            [strDesc appendFormat:@" Location: %@", data.address];
        }
        
        [self.mLblDesc setText:strDesc];
        
        // review num
        NSString *strReviewNum = [NSString stringWithFormat:@"%ld", data.mnReviewCount];
        [self.mButReviewNum setTitle:strReviewNum forState:UIControlStateNormal];
        [self.mButReviewNum setEnabled:YES];
    }
    else {
        [self.mLblName setText:username];
        [self.mButReviewNum setEnabled:NO];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat fHeight = 148 + (screenRect.size.height - 480) / 2;
    
    CGFloat fWidthPhotoView = fHeight - 56;
    
    double dRadius = fWidthPhotoView / 2;
    [self.mViewPhotoBack.layer setMasksToBounds:YES];
    [self.mViewPhotoBack.layer setCornerRadius:dRadius];
    
    dRadius -= 8;
    [self.mImgViewPhoto.layer setMasksToBounds:YES];
    [self.mImgViewPhoto.layer setCornerRadius:dRadius];
    
    [self.mCstTopMargin setConstant:self.mViewPhotoBack.frame.size.height / 2];
}


@end
