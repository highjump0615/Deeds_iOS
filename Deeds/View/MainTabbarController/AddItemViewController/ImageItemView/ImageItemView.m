//
//  ImageItemView.m
//  Deeds
//
//  Created by highjump on 15-4-20.
//
//

#import "ImageItemView.h"

@interface ImageItemView()

@end

@implementation ImageItemView

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
    
    [self.mButPhoto.layer setMasksToBounds:YES];
    [self.mButPhoto.layer setCornerRadius:3];
}

+ (id)itemView {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ImageItemView" owner:nil options:nil];
    ImageItemView *view = [[ImageItemView alloc] init];
    view = (ImageItemView *)[nib objectAtIndex:0];
    
    [view.mButClose setHidden:YES];
    
    return view;
}

- (void)setItemImage:(UIImage *)image {
    [self.mButPhoto setImage:image forState:UIControlStateNormal];
    
    if (image) {
        [self.mButClose setHidden:NO];
    }
    else {
        [self.mButClose setHidden:YES];
    }
}


@end
