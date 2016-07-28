//
//  FullImageView.m
//  Deeds
//
//  Created by highjump on 15-4-23.
//
//

#import "FullImageView.h"
#import "UIImageView+WebCache.h"

#import <Parse/Parse.h>


@interface FullImageView() <UIScrollViewDelegate> {
    CGRect mrtFrameFrom;
    NSInteger mnCurIndex;
    NSInteger mnCount;
}

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView1;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView2;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView3;

@property (weak, nonatomic) IBOutlet UIImageView *mImgView1;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView2;
@property (weak, nonatomic) IBOutlet UIImageView *mImgView3;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstWidth2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstWidth3;

@property (strong) UIView *mViewParent;


@end

@implementation FullImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [self.mScrollView1 setDelegate:self];
    self.mScrollView1.minimumZoomScale = 1.0;
    self.mScrollView1.maximumZoomScale = 6.0;
    
    [self.mScrollView2 setDelegate:self];
    self.mScrollView2.minimumZoomScale = 1.0;
    self.mScrollView2.maximumZoomScale = 6.0;
    
    [self.mScrollView3 setDelegate:self];
    self.mScrollView3.minimumZoomScale = 1.0;
    self.mScrollView3.maximumZoomScale = 6.0;
}


+ (id)initView:(UIView *)parentView
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FullImageView" owner:nil options:nil];
    FullImageView *view = [[FullImageView alloc] init];
    view = (FullImageView *)[nib objectAtIndex:0];
    view.mViewParent = parentView;
    
    return view;
}

- (void)setItemParseImages:(NSArray *)aryFile {
    mnCount = [aryFile count];
    
    PFFile *filePhoto = [aryFile objectAtIndex:0];
    [self.mImgView1 sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    
    filePhoto = [aryFile objectAtIndex:1];
    [self.mImgView2 sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
    
    filePhoto = [aryFile objectAtIndex:2];
    [self.mImgView3 sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                      placeholderImage:[UIImage imageNamed:@"home_item_default.png"]];
}

- (void)setItemImages:(NSArray *)aryImage {
    
    mnCount = [aryImage count];
    
    if ([aryImage count] < 1) {
        return;
    }
    [self.mImgView1 setImage:[aryImage objectAtIndex:0]];
    
    if ([aryImage count] < 2) {
        return;
    }
    [self.mImgView2 setImage:[aryImage objectAtIndex:1]];
    
    if ([aryImage count] < 3) {
        return;
    }
    [self.mImgView3 setImage:[aryImage objectAtIndex:2]];
}


- (void)showView:(CGRect)frameFrom index:(NSInteger)nIndex {
    
    mnCurIndex = nIndex;
    
    [self setFrame:frameFrom];
    [self layoutIfNeeded];
    
//    [self.mImgView sd_setImageWithURL:[NSURL URLWithString:strUrl]
//                     placeholderImage:[UIImage imageNamed:@"photo_sample.png"]];
//    
    // add tap guesture
    if ([self.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(didRecognizeSingleTap:)];
        [singleTapRecognizer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTapRecognizer];
    }
    
    [self.mViewParent addSubview:self];
    
    // we have to give delay time to make ready layout
    [self performSelector:@selector(expandShow:) withObject:nil afterDelay:0.01];
    
    
    mrtFrameFrom = frameFrom;
}

- (void)expandShow:(id)sender {
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setFrame:self.mViewParent.frame];
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         //						 self.view.userInteractionEnabled = YES;
                     }];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint ptOffset = self.mScrollView.contentOffset;
    [self.mScrollView setContentOffset:CGPointMake(mnCurIndex * self.mScrollView.frame.size.width, ptOffset.y)
                              animated:NO];
    
    if (mnCount < 3) {
        [self.mCstWidth3 setConstant:-self.mScrollView.frame.size.width];
    }
    if (mnCount < 2) {
        [self.mCstWidth2 setConstant:self.mScrollView.frame.size.width];
    }
}

- (void)didRecognizeSingleTap:(id)sender
{
    // close view
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self setFrame:mrtFrameFrom];
                         [self layoutIfNeeded];
                     }completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView == self.mScrollView1) {
        return self.mImgView1;
    }
    else if (scrollView == self.mScrollView2) {
        return self.mImgView2;
    }
    else if (scrollView == self.mScrollView3) {
        return self.mImgView3;
    }
    
    return nil;
}


@end
