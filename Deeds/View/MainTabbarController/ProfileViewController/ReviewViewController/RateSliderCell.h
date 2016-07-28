//
//  RateSliderCell.h
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import <UIKit/UIKit.h>

@protocol RateSliderCellDelegate

- (void)setRateType:(NSInteger)value;

@end


@interface RateSliderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mLblTitle;
@property (strong) id <RateSliderCellDelegate> delegate;

@end
