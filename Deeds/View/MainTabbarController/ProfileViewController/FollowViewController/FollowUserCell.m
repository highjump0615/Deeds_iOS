//
//  FollowUserCell.m
//  Deeds
//
//  Created by highjump on 15-5-4.
//
//

#import "FollowUserCell.h"
#import "UIImageView+WebCache.h"

#import "UserData.h"
#import "CommonUtils.h"


@interface FollowUserCell() {
    UserData *mUserData;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;
@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;
@property (weak, nonatomic) IBOutlet UILabel *mLblDistance;
@property (weak, nonatomic) IBOutlet UIButton *mButFollow;
@property (weak, nonatomic) IBOutlet UIButton *mButFollow1;

@end


@implementation FollowUserCell

- (void)awakeFromNib {
    // Initialization code
    [self.mButFollow.layer setCornerRadius:3];
    [self.mButFollow1.layer setCornerRadius:3];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)data {
    
    mUserData = data;
    
    PFFile *filePhoto = data.photo;
    [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                          placeholderImage:[UIImage imageNamed:@"user_default.png"]];
    
    [self.mLblUsername setText:[data getUsernameToShow]];
    
    CommonUtils *utils = [CommonUtils sharedObject];
    CGFloat fDist = [utils getDistanceFromPoint:data.location];
    NSString *strDistance;
    
    if (fDist < 0) {
        strDistance = @"Unknown";
    }
    else {
        strDistance = [NSString stringWithFormat:@"%.0fKM Away", fDist];
    }
    
    [self.mLblDistance setText:strDistance];

    [self updateFollowButton:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    double dRadius = self.mImgViewPhoto.frame.size.height / 2;
    [self.mImgViewPhoto.layer setMasksToBounds:YES];
    [self.mImgViewPhoto.layer setCornerRadius:dRadius];
}

- (void)updateFollowButton:(id)sender {
    
    UserData *currentUser = [UserData currentUser];
    UIColor *colorRed = [UIColor colorWithRed:246/255.0 green:105/255.0 blue:104/255.0 alpha:1.0];
    CommonUtils *utils = [CommonUtils sharedObject];
    
    if ([currentUser isUserFollowing:mUserData]) {
        [self.mButFollow setTitleColor:colorRed forState:UIControlStateNormal];
        [self.mButFollow setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
        
        [self.mButFollow1 setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
        [self.mButFollow1 setTitle:@"FOLLOW" forState:UIControlStateNormal];
    }
    else {
        [self.mButFollow setTitleColor:utils.mColorTheme forState:UIControlStateNormal];
        [self.mButFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
        
        [self.mButFollow1 setTitleColor:colorRed forState:UIControlStateNormal];
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
    
    [self performSelector:@selector(updateFollowButton:) withObject:nil afterDelay:0.4];
    
//    [self updateFollowButton];
}



@end
