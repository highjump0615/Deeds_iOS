//
//  DetailCommentCell.h
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import <UIKit/UIKit.h>

@class NotificationData;

@interface DetailCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButUser;
@property (nonatomic) CGFloat mfHeight;


- (void)fillContent:(NotificationData *)data forHeight:(BOOL)bForHeight;


@end
