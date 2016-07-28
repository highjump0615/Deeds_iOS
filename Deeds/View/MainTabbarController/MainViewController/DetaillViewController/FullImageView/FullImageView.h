//
//  FullImageView.h
//  Deeds
//
//  Created by highjump on 15-4-23.
//
//

#import <UIKit/UIKit.h>


@interface FullImageView : UIView

+ (id)initView:(UIView *)parentView;

- (void)showView:(CGRect)frameFrom index:(NSInteger)nIndex;

- (void)setItemParseImages:(NSArray *)aryFile;
- (void)setItemImages:(NSArray *)aryImage;

@end
