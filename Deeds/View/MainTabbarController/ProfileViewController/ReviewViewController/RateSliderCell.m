//
//  RateSliderCell.m
//  Deeds
//
//  Created by highjump on 15-5-6.
//
//

#import "RateSliderCell.h"
#import "SEFilterControl.h"

#import "CommonUtils.h"


@interface RateSliderCell() {
    SEFilterControl *mSlider;
}

@property (weak, nonatomic) IBOutlet UIView *mViewSlider;

@end

@implementation RateSliderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (mSlider) {
        [mSlider removeFromSuperview];
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CommonUtils *utils = [CommonUtils sharedObject];
    
    mSlider = [[SEFilterControl alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 16, self.mViewSlider.frame.size.height)
                                              Titles:[NSArray arrayWithObjects:@"Normal", @"Good", @"Amazing", nil]];
    [mSlider setProgressColor:utils.mColorTheme];
    [mSlider setHandlerColor:[UIColor whiteColor]];
    [mSlider setTitlesColor:utils.mColorGray];
    [mSlider addTarget:self action:@selector(filterValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.mViewSlider addSubview:mSlider];
}

-(void)filterValueChanged:(SEFilterControl *) sender{
    if (self.delegate) {
        [self.delegate setRateType:sender.SelectedIndex];
    }
}


@end
