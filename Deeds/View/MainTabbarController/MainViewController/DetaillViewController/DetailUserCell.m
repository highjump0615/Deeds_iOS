//
//  DetailUserCell.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "DetailUserCell.h"

#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

#import "UserData.h"
#import "ItemData.h"
#import "NotificationData.h"

@interface DetailUserCell() {
    ItemData *mItemData;
}

@property (weak, nonatomic) IBOutlet UIView *mViewCommentUser;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewCommentUser;

@property (weak, nonatomic) IBOutlet UILabel *mButUsername;
@property (weak, nonatomic) IBOutlet UIButton *mButFollow;

@end

@implementation DetailUserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(ItemData *)data {
    // user info
    UserData *user = data.user;
    
    PFFile *filePhoto;
    if (user.createdAt) { // fetched
        filePhoto = user.photo;
        
        [self.mButUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                 forState:UIControlStateNormal
                         placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        
        [self.mButUsername setText:[user getUsernameToShow]];
    }
    else {
        [self.mButUsername setText:data.username];
    }
    
    UserData *currentUser = [UserData currentUser];
    filePhoto = currentUser.photo;
    
    [self.mImgViewCommentUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                placeholderImage:[UIImage imageNamed:@"user_default.png"]];
    
    mItemData = data;
    [self updateButton];
}

- (void)updateButton {
    UserData *currentUser = [UserData currentUser];
    
    if ([currentUser isUserFollowing:mItemData.user]) {
        [self.mButFollow setImage:[UIImage imageNamed:@"detail_follow.png"]
                         forState:UIControlStateNormal];
    }
    else {
        [self.mButFollow setImage:[UIImage imageNamed:@"detail_follow_plus.png"]
                         forState:UIControlStateNormal];
    }
}

- (IBAction)onButFollow:(id)sender {
    
    UserData *currentUser = [UserData currentUser];
    [currentUser doFollow:mItemData.user];
    
    [self updateButton];
    
    if ([currentUser isUserFollowing:mItemData.user]) {
        //
        // like animation
        //
        CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        [pulseAnimation setDuration:0.2];
        [pulseAnimation setRepeatCount:3];
        
        // The built-in ease in/ ease out timing function is used to make the animation look smooth as the layer
        // animates between the two scaling transformations.
        [pulseAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        // Scale the layer to half the size
        CATransform3D transform = CATransform3DMakeScale(2.0, 2.0, 1.0);
        
        // Tell CA to interpolate to this transformation matrix
        [pulseAnimation setToValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
        [pulseAnimation setToValue:[NSValue valueWithCATransform3D:transform]];
        
        // Tells CA to reverse the animation (e.g. animate back to the layer's transform)
        [pulseAnimation setAutoreverses:YES];
        
        // Finally... add the explicit animation to the layer... the animation automatically starts.
        [self.mButFollow.imageView.layer addAnimation:pulseAnimation forKey:@"BTSPulseAnimation"];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    double dRadius = self.mButUser.frame.size.height / 2;
    [self.mButUser.layer setMasksToBounds:YES];
    [self.mButUser.layer setCornerRadius:dRadius];
    
    dRadius = self.mViewCommentUser.frame.size.height / 2;
    [self.mViewCommentUser.layer setMasksToBounds:YES];
    [self.mViewCommentUser.layer setCornerRadius:dRadius];
    
    dRadius = self.mImgViewCommentUser.frame.size.height / 2;
    [self.mImgViewCommentUser.layer setMasksToBounds:YES];
    [self.mImgViewCommentUser.layer setCornerRadius:dRadius];
}

@end
