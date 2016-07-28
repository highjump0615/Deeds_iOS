//
//  NotificationCommentCell.m
//  Deeds
//
//  Created by highjump on 15-4-22.
//
//

#import "NotificationCommentCell.h"

#import "NotificationData.h"


@interface NotificationCommentCell()

@property (weak, nonatomic) IBOutlet UILabel *mLblContent;

@end


@implementation NotificationCommentCell

- (void)fillContent:(NotificationData *)data forHeight:(BOOL)bForHeight {
    
    if (bForHeight) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat fLabelWidth = screenWidth - 66;
        
        self.mfHeight = 57 - 40;
        
        // title height
        CGSize constrainedSize = CGSizeMake(fLabelWidth, 9999);
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont systemFontOfSize:11],
                                              NSFontAttributeName,
                                              nil];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:data.comment
                                                                                   attributes:attributesDictionary];
        CGRect requiredHeight = [string boundingRectWithSize:constrainedSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                     context:nil];
        self.mfHeight += requiredHeight.size.height	;
        self.mfHeight = ceil(self.mfHeight);
        
        return;
    }
    
    // content
    [self.mLblContent setText:data.comment];
}


@end
