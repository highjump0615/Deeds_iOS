//
//  DetailContactView.h
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import <UIKit/UIKit.h>

@class ItemData;

@interface DetailContactView : UIView

@property (weak, nonatomic) IBOutlet UIButton *mButPhone;
@property (weak, nonatomic) IBOutlet UIButton *mButEmail;


- (void)initView;
- (void)setContent:(ItemData *)data;
- (void)showView:(BOOL)bShow animated:(BOOL)animated;

@end
