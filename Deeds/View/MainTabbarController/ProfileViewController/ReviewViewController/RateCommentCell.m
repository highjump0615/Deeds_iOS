//
//  RateCommentCell.m
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import "RateCommentCell.h"
#import "PlaceholderTextView.h"

#import "UIImageView+WebCache.h"

#import "UserData.h"


@interface RateCommentCell()

@property (weak, nonatomic) IBOutlet UIView *mViewCommentUser;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewCommentUser;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewBg;
@property (weak, nonatomic) IBOutlet PlaceholderTextView *mTextComment;

@end


@implementation RateCommentCell

- (void)awakeFromNib {
    // Initialization code
    UIImage* image = [UIImage imageNamed:@"rate_comment_frame.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(28, 10, 3, 3);
    image = [image resizableImageWithCapInsets:insets];
    
    [self.mImgViewBg setImage:image];
    
    [self.mTextComment setPlaceholder:@"Leave a Comment ..."];
    
    UserData *currentUser = [UserData currentUser];
    PFFile *filePhoto = currentUser.photo;
    
    [self.mImgViewCommentUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                placeholderImage:[UIImage imageNamed:@"user_default.png"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    double dRadius = self.mViewCommentUser.frame.size.height / 2;
    [self.mViewCommentUser.layer setMasksToBounds:YES];
    [self.mViewCommentUser.layer setCornerRadius:dRadius];
    
    dRadius = self.mImgViewCommentUser.frame.size.height / 2;
    [self.mImgViewCommentUser.layer setMasksToBounds:YES];
    [self.mImgViewCommentUser.layer setCornerRadius:dRadius];
}


@end
