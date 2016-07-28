//
//  FollowViewController.h
//  Deeds
//
//  Created by highjump on 15-5-4.
//
//

#import <UIKit/UIKit.h>

@class UserData;

typedef enum {
    FOLLOW_FOLLOWER = 0,
    FOLLOW_FOLLOWING
} FollowType;



@interface FollowViewController : UIViewController

@property (strong) UserData *mUser;
@property (nonatomic) NSInteger mnType;

@end
