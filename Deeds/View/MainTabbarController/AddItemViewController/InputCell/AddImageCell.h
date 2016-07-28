//
//  AddImageCell.h
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "AddInputViewCell.h"

@protocol AddImageCellDelegate

- (void)onRemoveItem:(NSInteger)nIndex;
- (void)onImageItem:(NSInteger)nIndex frame:(CGRect)rtFrame;
- (void)setItemImage:(UIImage *)image index:(NSInteger)nIndex;

@end


@interface AddImageCell : AddInputViewCell

@property (weak, nonatomic) IBOutlet UIButton *mButTakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *mButChoosePhoto;

@property (strong) id <AddImageCellDelegate> delegate;


- (void)fillContent:(NSArray *)aryImageItem isImage:(BOOL)bIsImage;

@end
