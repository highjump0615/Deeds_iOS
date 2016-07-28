//
//  ReviewCommentCell.m
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import "ReviewCommentCell.h"

#import "CommonUtils.h"

#import "NotificationData.h"
#import "UserData.h"

#import "UIButton+WebCache.h"


@interface ReviewCommentCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewRate;
@property (weak, nonatomic) IBOutlet UILabel *mLblRate;
@property (weak, nonatomic) IBOutlet UILabel *mLblComment;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;

@end


@implementation ReviewCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(NotificationData *)data forHeight:(BOOL)bForHeight {
    if (bForHeight) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat fLabelWidth = screenWidth - 66;
        
        self.mfHeight = 91 - 29;
        
        // title height
        CGSize constrainedSize = CGSizeMake(fLabelWidth, 9999);
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:11],
                                              NSFontAttributeName,
                                              nil];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:data.comment
                                                                                   attributes:attributesDictionary];
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                     context:nil];
        self.mfHeight += requiredHeight.size.height	;
        self.mfHeight = ceil(self.mfHeight);
        
        return;
    }
    
    //
    // user info
    //
    UserData *user = data.user;
    
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *filePhoto = user.photo;
        [self.mButUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                 forState:UIControlStateNormal
                         placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        
        [self.mButUsername setTitle:[user getUsernameToShow] forState:UIControlStateNormal];
    }];

    [self.mButUsername setTitle:data.username forState:UIControlStateNormal];
    
    // content
    [self.mLblComment setText:data.comment];
    
    // date
    NSString *strTime = [CommonUtils getTimeString:data.createdAt];
    [self.mLblTime setText:strTime];
    
    // rate
    if (data.rate == RATE_NORMAL) {
        [self.mImgViewRate setImage:[UIImage imageNamed:@"review_bad.png"]];
        [self.mLblRate setText:@"Normal"];
    }
    else if (data.rate == RATE_GOOD) {
        [self.mImgViewRate setImage:[UIImage imageNamed:@"review_normal.png"]];
        [self.mLblRate setText:@"Good"];
    }
    else {
        [self.mImgViewRate setImage:[UIImage imageNamed:@"review_good.png"]];
        [self.mLblRate setText:@"Amazing"];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblComment.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblComment.frame);
    
    double dRadius = self.mButUser.frame.size.height / 2;
    [self.mButUser.layer setMasksToBounds:YES];
    [self.mButUser.layer setCornerRadius:dRadius];
}


@end
