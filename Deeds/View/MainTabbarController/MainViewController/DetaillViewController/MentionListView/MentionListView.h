//
//  MentionListView.h
//  Deeds
//
//  Created by highjump on 15-5-7.
//
//

#import <UIKit/UIKit.h>


@interface MentionListView : UIView

@property (weak, nonatomic) IBOutlet UITableView *mTableView;


+ (id)viewWithFrame:(CGRect)frame position:(BOOL)bUp;
- (void)setViewHeight:(CGFloat)height;

@end
