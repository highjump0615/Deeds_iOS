//
//  MentionListView.m
//  Deeds
//
//  Created by highjump on 15-5-7.
//
//

#import "MentionListView.h"


@interface MentionListView() {
    UIImage *mImgFrameUp;
    UIImage *mImgFrameDown;
    
    BOOL mbUp;
}

@property (weak, nonatomic) IBOutlet UIImageView *mImgViewBg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstBottomMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mCstTopMargin;

@end

@implementation MentionListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    mImgFrameUp = [UIImage imageNamed:@"mention_frame_up.png"];
    UIEdgeInsets insets = UIEdgeInsetsMake(2, 30, 9, 4);
    mImgFrameUp = [mImgFrameUp resizableImageWithCapInsets:insets];
    
    mImgFrameDown = [UIImage imageNamed:@"mention_frame_down.png"];
    insets = UIEdgeInsetsMake(9, 30, 2, 4);
    mImgFrameDown = [mImgFrameDown resizableImageWithCapInsets:insets];
}

+ (id)viewWithFrame:(CGRect)frame position:(BOOL)bUp {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MentionListView" owner:nil options:nil];
    MentionListView *view = [[MentionListView alloc] init];
    view = (MentionListView *)[nib objectAtIndex:0];
    
    [view initView:frame position:bUp];
    
    return view;
}

- (void)initView:(CGRect)frame position:(BOOL)bUp {
    mbUp = bUp;
    
    [self setFrame:frame];
    
    if (bUp) {
        [self.mImgViewBg setImage:mImgFrameUp];
    }
    else {
        [self.mImgViewBg setImage:mImgFrameDown];
    }
}

- (void)setViewHeight:(CGFloat)height {
    CGRect rtFrame = self.frame;
    
    if (mbUp) {
        rtFrame.origin.y = rtFrame.origin.y + rtFrame.size.height - height;
    }
    
    rtFrame.size.height = height;
    [self setFrame:rtFrame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (mbUp) {
        [self.mCstBottomMargin setConstant:8];
        [self.mCstTopMargin setConstant:1];
    }
    else {
        [self.mCstBottomMargin setConstant:1];
        [self.mCstTopMargin setConstant:8];
    }

}

@end
