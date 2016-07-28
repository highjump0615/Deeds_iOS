//
//  CommonUtils.m
//  Deeds
//
//  Created by highjump on 15-4-11.
//
//

#import "CommonUtils.h"

#import "UserData.h"

@implementation CommonUtils

+ (id)sharedObject {
    
    static CommonUtils* utils = nil;
    if (utils == nil) {
        utils = [[CommonUtils alloc] init];
        
        utils.mColorTheme = [UIColor colorWithRed:73/255.0 green:161/255.0 blue:221/255.0 alpha:1.0];
        utils.mColorGray = [UIColor colorWithRed:110/255.0 green:114/255.0 blue:119/255.0 alpha:1.0];
        utils.mColorYellow = [UIColor colorWithRed:255/255.0 green:195/255.0 blue:13/255.0 alpha:1.0];
        
        utils.mszProfilePhoto = CGSizeMake(116, 116);
        
        utils.maryCategory = [[NSMutableArray alloc] init];
        
        // init filter parameter
        utils.mbFilterDeed = YES;
        utils.mbFilterNeed = YES;
        utils.mbFilterFollow = NO;
        utils.mfFilterDistance = 500;
    }
    
    return utils;
}


- (CGFloat)getDistanceFromPoint:(PFGeoPoint *)point {
    PFGeoPoint *pointUser;
    UserData *currentUser = [UserData currentUser];
    
    if (self.mLocationCurrent) {
        // Query for posts sort of kind of near our current location.
        pointUser = [PFGeoPoint geoPointWithLatitude:self.mLocationCurrent.coordinate.latitude
                                           longitude:self.mLocationCurrent.coordinate.longitude];
    }
    else {
        pointUser = currentUser.location;
    }
    
    if (!pointUser || pointUser.latitude == 0 || pointUser.longitude == 0) {
        return -1;
    }
    
    if (point.latitude == 0 || point.longitude == 0) {
        return -1;
    }
    
    CGFloat distanceDouble = [pointUser distanceInKilometersTo:point];
    
    return distanceDouble;
}

+ (NSString *)getTimeString:(NSDate *)date {
    
    NSString *strTime = @"";
    
    NSTimeInterval time = -[date timeIntervalSinceNow];
    int min = (int)time / 60;
    int hour = min / 60;
    int day = hour / 24;
    int month = day / 30;
    int year = month / 12;
    
    if(min < 60) {
        strTime = [NSString stringWithFormat:@"%d min ago", min];
    }
    else if(min >= 60 && min < 60 * 24) {
        if(hour < 24) {
            strTime = [NSString stringWithFormat:@"%d hours ago", hour];
        }
    }
    else if (day < 31) {
        strTime = [NSString stringWithFormat:@"%d days ago", day];
    }
    else if (month < 12) {
        strTime = [NSString stringWithFormat:@"%d months ago", month];
    }
    else {
        strTime = [NSString stringWithFormat:@"%d years ago", year];
    }
    
    return strTime;
}


#pragma mark - Image Processing

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToWidth:(float)i_width
{
    //    float oldWidth = sourceImage.size.width;
    //    float scaleFactor = i_width / oldWidth;
    //
    //    float newHeight = sourceImage.size.height * scaleFactor;
    //    float newWidth = oldWidth * scaleFactor;
    //
    //    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight), NO, 0.0);
    //    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    //    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return newImage;
    
    if(sourceImage.size.width > i_width)
    {
        float fScale = sourceImage.size.width / i_width;
        
        UIGraphicsBeginImageContext(CGSizeMake(floor(i_width), floor(sourceImage.size.height / fScale)));
        [sourceImage drawInRect:CGRectMake(0, 0, floor(i_width), floor(sourceImage.size.height / fScale))];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return smallImage;
    }
    else
        return sourceImage;
}



@end
