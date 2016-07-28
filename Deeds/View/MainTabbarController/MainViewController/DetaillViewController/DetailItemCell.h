//
//  DetailItemCell.h
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import <UIKit/UIKit.h>

@class ItemData;

@interface DetailItemCell : UITableViewCell

@property (nonatomic) CGFloat mfHeight;

@property (weak, nonatomic) IBOutlet UIImageView *mImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView2;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView3;

@property (weak, nonatomic) id delegate;


- (void)fillContent:(ItemData *)data forHeight:(BOOL)bForHeight;

@end
