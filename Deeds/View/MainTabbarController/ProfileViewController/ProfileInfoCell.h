//
//  ProfileInfoCell.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@interface ProfileInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *mViewPhotoBack;
@property (weak, nonatomic) IBOutlet UIButton *mButFollowing;
@property (weak, nonatomic) IBOutlet UIButton *mButFollower;


- (void)fillContent:(UserData *)data username:(NSString *)username;

@end
