//
//  CommonUtils.h
//  Deeds
//
//  Created by highjump on 15-4-11.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class FBSDKAccessToken;
@class FBSDKProfile;
@class PFGeoPoint;

@class CLLocation;
@class CategoryData;

@interface CommonUtils : NSObject

@property (nonatomic, retain) UIColor *mColorTheme;
@property (nonatomic, retain) UIColor *mColorGray;
@property (nonatomic, retain) UIColor *mColorYellow;

@property (nonatomic) CGSize mszProfilePhoto;

@property (nonatomic, retain) UITabBarController *mTabbarController;

// about facebook
@property (nonatomic, retain) FBSDKAccessToken *mFBCurToken;
@property (nonatomic, retain) FBSDKProfile *mFBCurProfile;

@property (retain, nonatomic) CLLocation* mLocationCurrent;

@property (nonatomic, retain) NSMutableArray *maryCategory;
@property (nonatomic, retain) CategoryData *mCategorySelected;

@property (nonatomic) BOOL mbFilterDeed;
@property (nonatomic) BOOL mbFilterNeed;
@property (nonatomic) BOOL mbFilterFollow;
@property (nonatomic) CGFloat mfFilterDistance;

@property (nonatomic) NSInteger mnItemcount;
@property (nonatomic) NSInteger mnItemdone;


+ (id)sharedObject;

- (CGFloat)getDistanceFromPoint:(PFGeoPoint *)point;
+ (NSString *)getTimeString:(NSDate *)date;


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width;

@end
