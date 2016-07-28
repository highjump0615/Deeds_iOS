//
//  RateProfileInfoCell.h
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import <UIKit/UIKit.h>

#import "ProfileInfoCell.h"


@interface RateProfileInfoCell : UITableViewCell

- (void)fillContent:(UserData *)data username:(NSString *)username;

@end
