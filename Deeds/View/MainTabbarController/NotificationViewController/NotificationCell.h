//
//  NotificationCell.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <UIKit/UIKit.h>


@class NotificationData;


@interface NotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButImg;


- (void)fillContent:(NotificationData *)data;

@end
