//
//  ProfileInfoCell.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "ProfileInfoCell.h"
#import "UIImageView+WebCache.h"

#import "UserData.h"

#import "CommonUtils.h"


@interface ProfileInfoCell() <UIScrollViewDelegate> {
    UserData *mUserData;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;

@property (weak, nonatomic) IBOutlet UILabel *mLblName;
@property (weak, nonatomic) IBOutlet UIButton *mButReviewNum;
@property (weak, nonatomic) IBOutlet UILabel *mLblDesc;
//@property (weak, nonatomic) IBOutlet UILabel *mLblAbout;
@property (weak, nonatomic) IBOutlet UITextView *mTxtAbout;

@property (weak, nonatomic) IBOutlet UIPageControl *mPageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;
@property (weak, nonatomic) IBOutlet UIButton *mButFollow;
@property (weak, nonatomic) IBOutlet UIButton *mButFollow1;
//@property (weak, nonatomic) IBOutlet UILabel *mLblFollow;

@end

@implementation ProfileInfoCell

- (void)awakeFromNib {
    // Initialization code
    [self.mScrollView setDelegate:self];
    
    [self.mButFollow.layer setMasksToBounds:YES];
    [self.mButFollow.layer setCornerRadius:3];
    
    [self.mButFollow1.layer setMasksToBounds:YES];
    [self.mButFollow1.layer setCornerRadius:3];
    
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
    
    mUserData = data;
    
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
        
        // about
//        [self.mTxtAbout setText:data.about];
        if ([data.about length] > 0) {
            UIColor *colorGrey = [UIColor colorWithRed:156/255.0 green:162/255.0 blue:172/255.0 alpha:1.0];
            self.mTxtAbout.attributedText = [[NSAttributedString alloc] initWithString:data.about
                                                                            attributes:@{NSForegroundColorAttributeName:colorGrey}];
            self.mTxtAbout.textAlignment = NSTextAlignmentCenter;
        }
        
        // review num
        NSString *strReviewNum = [NSString stringWithFormat:@"%ld", data.mnReviewCount];
        [self.mButReviewNum setTitle:strReviewNum forState:UIControlStateNormal];
        [self.mButReviewNum setEnabled:YES];
    }
    else {
        [self.mLblName setText:username];
        [self.mButReviewNum setEnabled:NO];
    }
    
    // follow
    UserData *currentUser = [UserData currentUser];
    if ([currentUser.objectId isEqualToString:data.objectId]) {
        [self.mButFollow setHidden:YES];
    }
    else {
        [self.mButFollow setHidden:NO];
        [self updateButton:nil];
    }
    
    NSString *strTitle = [NSString stringWithFormat:@"%ld Following", [data.maryFollowingUser count]];
    [self.mButFollowing setTitle:strTitle forState:UIControlStateNormal];
    
    strTitle = [NSString stringWithFormat:@"%ld Followers", [data.maryFollowerUser count]];
    [self.mButFollower setTitle:strTitle forState:UIControlStateNormal];
    
//    [self.mLblFollow setText:[NSString stringWithFormat:@"%ld Following   %ld Followers",
//                              [data.maryFollowingUser count],
//                              [data.maryFollowerUser count]]];
}

- (void)updateButton:(id)sender {
    UserData *currentUser = [UserData currentUser];
    
    [self.mButFollow.layer setOpacity:1];
    [self.mButFollow setAlpha:1];
    
    if ([currentUser isUserFollowing:mUserData]) {
        [self.mButFollow setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
        [self.mButFollow1 setTitle:@"FOLLOW" forState:UIControlStateNormal];
    }
    else {
        [self.mButFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [self.mButFollow1 setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
    }
}

- (IBAction)onButFollow:(id)sender {
    UserData *currentUser = [UserData currentUser];
    
    if ([currentUser isUserFollowing:mUserData]) {
        [currentUser doUnFollow:mUserData];
    }
    else {
        [currentUser doFollow:mUserData];
    }
    
    // front
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.4;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    [self.mButFollow.layer addAnimation:animation forKey:@"opacityOUT"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.4;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    CATransform3D transform = CATransform3DMakeScale(2.0, 2.0, 1.0);
    
    [animation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [animation setToValue:[NSValue valueWithCATransform3D:transform]];
    
    [self.mButFollow.layer addAnimation:animation forKey:@"IncreaseAnimation"];
    
    // back
    animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.4;
    animation.fromValue = [NSNumber numberWithFloat:0.5f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.additive = NO;
    [self.mButFollow1.layer addAnimation:animation forKey:@"opacityIn"];
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.4;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    transform = CATransform3DMakeScale(0.3, 0.3, 1.0);
    [animation setFromValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [animation setFromValue:[NSValue valueWithCATransform3D:transform]];
    
    transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    [animation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [animation setToValue:[NSValue valueWithCATransform3D:transform]];
    
    [self.mButFollow1.layer addAnimation:animation forKey:@"IncreaseAnimation"];
    
    [self performSelector:@selector(updateButton:) withObject:nil afterDelay:0.4];
//    [self updateButton:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.mScrollView.frame.size.width;
    NSInteger nPage = self.mScrollView.contentOffset.x / pageWidth;
    // Update the page control
    self.mPageControl.currentPage = nPage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    double dRadius = self.mViewPhotoBack.frame.size.height / 2;
    [self.mViewPhotoBack.layer setMasksToBounds:YES];
    [self.mViewPhotoBack.layer setCornerRadius:dRadius];
    
    dRadius = self.mImgViewPhoto.frame.size.height / 2;
    [self.mImgViewPhoto.layer setMasksToBounds:YES];
    [self.mImgViewPhoto.layer setCornerRadius:dRadius];
}


@end
