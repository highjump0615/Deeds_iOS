//
//  NotificationCommentCell.h
//  Deeds
//
//  Created by highjump on 15-4-22.
//
//

#import <UIKit/UIKit.h>


@class NotificationData;

@interface NotificationCommentCell : UITableViewCell

@property (nonatomic) CGFloat mfHeight;


- (void)fillContent:(NotificationData *)data forHeight:(BOOL)bForHeight;

@end
