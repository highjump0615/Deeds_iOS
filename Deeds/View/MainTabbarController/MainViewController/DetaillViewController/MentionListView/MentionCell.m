//
//  MentionCell.m
//  Deeds
//
//  Created by highjump on 15-5-7.
//
//

#import "MentionCell.h"

#import "UserData.h"

#import "UIImageView+WebCache.h"


@interface MentionCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewUser;
@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;

@end


@implementation MentionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillContent:(UserData *)data {
    
    PFFile *filePhoto = data.photo;
    [self.mImgViewUser sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                         placeholderImage:[UIImage imageNamed:@"user_default.png"]];
    
    [self.mLblUsername setText:[data getUsernameToShow]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    double dRadius = self.mImgViewUser.frame.size.height / 2;
    [self.mImgViewUser.layer setMasksToBounds:YES];
    [self.mImgViewUser.layer setCornerRadius:dRadius];
}


@end
