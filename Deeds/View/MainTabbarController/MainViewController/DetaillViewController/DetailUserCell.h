//
//  DetailUserCell.h
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import <UIKit/UIKit.h>

@class ItemData;

@interface DetailUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButUser;
@property (weak, nonatomic) IBOutlet UITextField *mTxtComment;

- (void)fillContent:(ItemData *)data;

@end
