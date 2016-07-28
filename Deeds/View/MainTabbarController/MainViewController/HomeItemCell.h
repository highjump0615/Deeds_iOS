//
//  HomeItemCell.h
//  Deeds
//
//  Created by highjump on 15-4-11.
//
//

#import <UIKit/UIKit.h>

@class ItemData;

@interface HomeItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButUserPhoto;
@property (weak, nonatomic) IBOutlet UIButton *mButUser;


- (void)fillContent:(ItemData *)data;

@end
