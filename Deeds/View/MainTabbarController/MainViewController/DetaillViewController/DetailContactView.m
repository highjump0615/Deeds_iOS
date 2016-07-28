//
//  DetailContactView.m
//  Deeds
//
//  Created by highjump on 15-4-12.
//
//

#import "DetailContactView.h"

#import "UIImageView+WebCache.h"

#import "ItemData.h"
#import "UserData.h"


@interface DetailContactView()

@property (weak, nonatomic) IBOutlet UIView *mViewPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *mImgViewPhoto;

@property (weak, nonatomic) IBOutlet UILabel *mLblUsername;

@end

@implementation DetailContactView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initView
{
    [self showView:NO animated:NO];
    
    // add tap guesture
    if ([self.gestureRecognizers count] == 0) {
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                       initWithTarget:self action:@selector(didRecognizeSingleTap:)];
        [singleTapRecognizer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTapRecognizer];
    }
    
}

- (void)setContent:(ItemData *)data {
    // photo
    UserData *user = data.user;
    
    if (user.createdAt) {
        PFFile *filePhoto = user.photo;
        [self.mImgViewPhoto sd_setImageWithURL:[NSURL URLWithString:filePhoto.url]
                              placeholderImage:[UIImage imageNamed:@"user_default.png"]];
        
        // name
        [self.mLblUsername setText:[user getUsernameToShow]];
        
        // phone & email
        [self.mButPhone setTitle:user.phone forState:UIControlStateNormal];
        [self.mButEmail setTitle:user.email forState:UIControlStateNormal];
    }
    else {
        [self.mLblUsername setText:data.username];
    }
}

- (void)showView:(BOOL)bShow animated:(BOOL)animated {
    
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             [self setHidden:NO];
                             [self setAlpha:bShow];
                         }completion:^(BOOL finished) {
                             [self setHidden:!bShow];
                         }];
    }
    else {
        [self setAlpha:bShow];
        [self setHidden:!bShow];
    }
}

- (void)didRecognizeSingleTap:(id)sender
{
    [self showView:NO animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    double dRadius = self.mViewPhoto.frame.size.height / 2;
    [self.mViewPhoto.layer setMasksToBounds:YES];
    [self.mViewPhoto.layer setCornerRadius:dRadius];
    
    dRadius = self.mImgViewPhoto.frame.size.height / 2;
    [self.mImgViewPhoto.layer setMasksToBounds:YES];
    [self.mImgViewPhoto.layer setCornerRadius:dRadius];
}

@end
