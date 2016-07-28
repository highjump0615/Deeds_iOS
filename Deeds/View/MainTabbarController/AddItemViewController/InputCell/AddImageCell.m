//
//  AddImageCell.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "AddImageCell.h"

#import "ImageItemView.h"
#import "UIBUtton+WebCache.h"

#import "CommonDefine.h"
#import <Parse/Parse.h>



@interface AddImageCell() {
    NSMutableArray *maryItemView;
    
    NSArray *maryImage;
    BOOL mbIsImage;
}

@property (weak, nonatomic) IBOutlet UIView *mViewButton;
@property (weak, nonatomic) IBOutlet UIView *mViewItem;

@end


@implementation AddImageCell

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

    [self.mViewButton.layer setMasksToBounds:YES];
    [self.mViewButton.layer setCornerRadius:2];
    
    maryItemView = [[NSMutableArray alloc] init];
}

- (void)fillContent:(NSArray *)aryImageItem isImage:(BOOL)bIsImage {
    maryImage = aryImageItem;
    mbIsImage = bIsImage;
}

- (void)showItemImages:(NSArray *)aryImageItem isImage:(BOOL)bIsImage {
    
    if ([maryItemView count] == 0) {
        return;
    }
    
    for (ImageItemView *iView in maryItemView) {
        [iView setItemImage:nil];
    }
    
    if ([aryImageItem count] == 0) {
        return;
    }
    
    
    int i = 0;
    
    if (bIsImage) {
        for (i = 0; i < [aryImageItem count]; i++) {
            UIImage *imgItem = [aryImageItem objectAtIndex:i];
            ImageItemView *iView = [maryItemView objectAtIndex:i];
            
            [iView setItemImage:imgItem];
        }
    }
    else {
        for (i = 0; i < [aryImageItem count]; i++) {
            PFFile *fileImg = [aryImageItem objectAtIndex:i];
            
            ImageItemView *iView = [maryItemView objectAtIndex:i];
            [iView.mButClose setHidden:NO];
            [iView.mButClose setEnabled:NO];
            
            [iView.mButPhoto sd_setImageWithURL:[NSURL URLWithString:fileImg.url]
                                       forState:UIControlStateNormal
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
             {
                 [iView.mButClose setEnabled:YES];
                 
                 if (self.delegate) {
                     [self.delegate setItemImage:image index:i];
                 }
             }];
            
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // remove all item views
    for (ImageItemView *itemView in maryItemView) {
        [itemView removeFromSuperview];
    }
    [maryItemView removeAllObjects];
    
    NSInteger nItemWidth = 0, nItemHeight;

    // add item views
    for (int i = 0; i < IMAGE_ITEM_COUNT; i++) {
        ImageItemView *itemView = [ImageItemView itemView];
        nItemWidth = itemView.frame.size.width;
        nItemHeight = itemView.frame.size.height;
        
        [itemView.mButPhoto addTarget:self action:@selector(onButPhoto:) forControlEvents:UIControlEventTouchUpInside];
        itemView.mButPhoto.tag = i;
        [itemView.mButClose addTarget:self action:@selector(onButClose:) forControlEvents:UIControlEventTouchUpInside];
        itemView.mButClose.tag = i;
        [itemView setFrame:CGRectMake(5 + i * (nItemWidth + 5), 0, nItemWidth, nItemHeight)];
        
        [maryItemView addObject:itemView];
        [self.mViewItem addSubview:itemView];
    }
    
    if (maryImage) {
        [self showItemImages:maryImage isImage:mbIsImage];
    }
}

- (void)onButPhoto:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger nIndex = [button tag];
    
    if (self.delegate) {
        CGRect rectInSuperview = [button convertRect:button.frame toView:self.contentView];
        [self.delegate onImageItem:nIndex frame:rectInSuperview];
    }
}

- (void)onButClose:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger nIndex = [button tag];
    
    if (self.delegate) {
        [self.delegate onRemoveItem:nIndex];
    }
}


@end
