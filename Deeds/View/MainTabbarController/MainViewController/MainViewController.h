//
//  MainViewController.h
//  Deeds
//
//  Created by highjump on 15-4-7.
//
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

- (void)reloadTable;
- (void)getBlogWithProgress:(BOOL)animation needRefresh:(BOOL)bRefresh;

@end
