//
//  ReviewCommentCell.h
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import <UIKit/UIKit.h>


@class NotificationData;

@interface ReviewCommentCell : UITableViewCell

@property (nonatomic) CGFloat mfHeight;

@property (weak, nonatomic) IBOutlet UIButton *mButUser;
@property (weak, nonatomic) IBOutlet UIButton *mButUsername;


- (void)fillContent:(NotificationData *)data forHeight:(BOOL)bForHeight;

@end
