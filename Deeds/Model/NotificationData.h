//
//  NotificationData.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef enum {
    NOTIFICATION_COMMENT = 0,
    NOTIFICATION_FAVOURITE,
    NOTIFICATION_FOLLOW,
    NOTIFICATION_RATE,
    NOTIFICATION_MENTION,
    NOTIFICATION_POST
} NotificationType;

typedef enum {
    RATE_NORMAL = 0,
    RATE_GOOD,
    RATE_AMAZING
} RateType;


@class ItemData;
@class UserData;

@interface NotificationData : PFObject <PFSubclassing>

@property (nonatomic) NotificationType type;
@property (nonatomic, retain) ItemData *item;
@property (nonatomic, retain) UserData *user;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) UserData *targetuser;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic) RateType rate;

@property (nonatomic) BOOL mbExpanded;

@end
