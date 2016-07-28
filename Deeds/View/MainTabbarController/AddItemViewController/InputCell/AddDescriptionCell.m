//
//  AddDescriptionCell.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "AddDescriptionCell.h"
#import "PlaceholderTextView.h"

@interface AddDescriptionCell()

@property (weak, nonatomic) IBOutlet PlaceholderTextView *mTxtContent;

@end

@implementation AddDescriptionCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    [self.mTxtContent setPlaceholder:@"Type description here"];
}


@end
