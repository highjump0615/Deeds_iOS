//
//  FavouriteCell.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@class ItemData;

@interface FavouriteCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButUserPhoto;
@property (weak, nonatomic) IBOutlet UIButton *mButUser;

- (void)fillContent:(ItemData *)data;

@end
