//
//  ImageItemView.h
//  Deeds
//
//  Created by highjump on 15-4-20.
//
//

#import <UIKit/UIKit.h>

@interface ImageItemView : UIView

@property (weak, nonatomic) IBOutlet UIButton *mButPhoto;
@property (weak, nonatomic) IBOutlet UIButton *mButClose;

+ (id)itemView;
- (void)setItemImage:(UIImage *)image;

@end
