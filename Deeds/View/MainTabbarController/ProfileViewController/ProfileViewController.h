//
//  ProfileViewController.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <UIKit/UIKit.h>

@class UserData;

@interface ProfileViewController : UIViewController

@property (strong) UserData *mUser;
@property (strong) NSString *mUsername;

@end
