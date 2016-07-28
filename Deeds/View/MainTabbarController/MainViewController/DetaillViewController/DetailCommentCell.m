//
//  DetailCommentCell.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "DetailCommentCell.h"

#import "CommonUtils.h"

#import "NotificationData.h"
#import "UserData.h"

#import "UIButton+WebCache.h"


@interface DetailCommentCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;
@property (weak, nonatomic) IBOutlet UILabel *mLblTime;

@end

@implementation DetailCommentCell

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
        
        self.mfHeight = 76 - 27;
        
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
    
//    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PFFile *filePhoto = user.photo;
        [self.mButUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        
        [self.mLblUsername setText:[user getUsernameToShow]];
//    }];
//    
//    [self.mLblUsername setText:data.username];
    
    // content
    [self.mLblContent setText:data.comment];
    
    // date
    NSString *strTime = [CommonUtils getTimeString:data.createdAt];
    [self.mLblTime setText:strTime];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.mLblContent.preferredMaxLayoutWidth = CGRectGetWidth(self.mLblContent.frame);
    
    double dRadius = self.mButUser.frame.size.height / 2;
    [self.mButUser.layer setMasksToBounds:YES];
    [self.mButUser.layer setCornerRadius:dRadius];
}


@end
