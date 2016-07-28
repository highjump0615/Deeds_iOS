//
//  AddCategoryCell.m
//  Deeds
//
//  Created by highjump on 15-5-21.
//
//

#import "AddCategoryCell.h"

@implementation AddCategoryCell

- (void)awakeFromNib {
    // Initialization code
    [self.mButEdit.layer setCornerRadius:2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
