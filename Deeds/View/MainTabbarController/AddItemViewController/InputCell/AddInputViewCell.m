
//
//  AddInputViewCell.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "AddInputViewCell.h"

@interface AddInputViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewFrame;

@end


@implementation AddInputViewCell

- (void)awakeFromNib {
    // Initialization code
    UIImage* image = [UIImage imageNamed:@"add_topic_frame.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 0, 32, 60);
    image = [image resizableImageWithCapInsets:insets];
    
    [self.mImgViewFrame setImage:image];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
}

@end
