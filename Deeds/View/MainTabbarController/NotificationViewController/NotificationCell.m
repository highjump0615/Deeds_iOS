//
//  NotificationCell.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "NotificationCell.h"

#import "CommonUtils.h"
#import "NotificationData.h"

@interface NotificationCell()

//@property (weak, nonatomic) IBOutlet UIImageView *mImgView;
@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (weak, nonatomic) IBOutlet UILabel *mLblContent;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewArrow;

@end

@implementation NotificationCell

- (void)awakeFromNib {
    CommonUtils *utils = [CommonUtils sharedObject];
    
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    [self.selectedBackgroundView setBackgroundColor:utils.mColorTheme];
    
    [self.mLblContent setHighlightedTextColor:[UIColor whiteColor]];
    [self.mLblTitle setHighlightedTextColor:[UIColor whiteColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
//    CommonUtils *utils = [CommonUtils sharedObject];
//
    // Configure the view for the selected state
//    if (selected) {
        [self.mButImg setHighlighted:selected];
//        [self.mImgView setImage:[UIImage imageNamed:@"notify_follow.png"]];
//        [self.mLblContent setTextColor:[UIColor whiteColor]];
//        [self.mLblTitle setTextColor:[UIColor whiteColor]];
//        [self setBackgroundColor:utils.mColorTheme];
//    }
}

- (void)fillContent:(NotificationData *)data {
    switch (data.type) {
        case NOTIFICATION_COMMENT:
            [self.mButImg setImage:[UIImage imageNamed:@"notify_comment.png"] forState:UIControlStateNormal];
            [self.mButImg setImage:[UIImage imageNamed:@"notify_comment_selected.png"] forState:UIControlStateHighlighted];
            
            [self.mLblTitle setText:@"You have got new comment"];
            
            break;
            
        case NOTIFICATION_FOLLOW:
            [self.mButImg setImage:[UIImage imageNamed:@"notify_follow.png"] forState:UIControlStateNormal];
            [self.mButImg setImage:[UIImage imageNamed:@"notify_follow_selected.png"] forState:UIControlStateHighlighted];
            
            [self.mLblTitle setText:[NSString stringWithFormat:@"%@ now follows you", data.username]];
            
            break;
            
        case NOTIFICATION_FAVOURITE:
            [self.mButImg setImage:[UIImage imageNamed:@"notify_favourite.png"] forState:UIControlStateNormal];
            [self.mButImg setImage:[UIImage imageNamed:@"notify_favourite_selected.png"] forState:UIControlStateHighlighted];
            
            [self.mLblTitle setText:[NSString stringWithFormat:@"%@ favorited your post", data.username]];
            
            break;
            
        case NOTIFICATION_RATE:
            [self.mButImg setImage:[UIImage imageNamed:@"notify_review.png"] forState:UIControlStateNormal];
            [self.mButImg setImage:[UIImage imageNamed:@"notify_review_selected.png"] forState:UIControlStateHighlighted];
            
            [self.mLblTitle setText:@"You have been rated"];
            
            break;
            
        case NOTIFICATION_MENTION:
            [self.mButImg setImage:[UIImage imageNamed:@"notify_mention.png"] forState:UIControlStateNormal];
            [self.mButImg setImage:[UIImage imageNamed:@"notify_mention_selected.png"] forState:UIControlStateHighlighted];
            
            [self.mLblTitle setText:@"You have been mentioned"];
            
            break;
            
        case NOTIFICATION_POST:
            [self.mButImg setImage:[UIImage imageNamed:@"notify_post.png"] forState:UIControlStateNormal];
            [self.mButImg setImage:[UIImage imageNamed:@"notify_post_selected.png"] forState:UIControlStateHighlighted];
            
            [self.mLblTitle setText:@"User you follow posted a new item"];
            
            break;
            
        default:
            break;
    }
    
    // date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormat setDateFormat:@"MMMM dd yyyy, HH:mm"];
    NSString *strDate = [dateFormat stringFromDate:data.createdAt];
    
    [self.mLblContent setText:strDate];
}

@end
