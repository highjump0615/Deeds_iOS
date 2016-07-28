//
//  DetailViewController.h
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import <UIKit/UIKit.h>

@class ItemData;

@interface DetailViewController : UIViewController

@property (strong) ItemData *mItem;

- (void)dismissKeyboard:(UITapGestureRecognizer *)sender;

@end
