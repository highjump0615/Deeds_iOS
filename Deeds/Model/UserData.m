//
//  UserData.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "UserData.h"
#import "ItemData.h"
#import "NotificationData.h"

#import <Parse/PFObject+Subclass.h>

@interface UserData()

@end

@implementation UserData

@dynamic firstname;
@dynamic lastname;
@dynamic fullname;
@dynamic phone;
@dynamic about;
@dynamic photo;
@dynamic address;
@dynamic location;
@dynamic favourite;
@dynamic follower;
@dynamic following;
@dynamic review;
//@dynamic reviewcount;

@synthesize maryFavouriteItem;
@synthesize maryFollowingUser;
@synthesize maryFollowerUser;
@synthesize maryReview;
@synthesize mnReviewCount;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"_User";
}

- (id)init {
    self = [super init];
    
    [self initData];
    
    return self;
}

- (void)initData {
    self.maryFavouriteItem = [[NSMutableArray alloc] init];
    
    self.maryFollowingUser = [[NSMutableArray alloc] init];
    self.maryFollowerUser = [[NSMutableArray alloc] init];
    
    self.maryReview = [[NSMutableArray alloc] init];
}

- (void)getFavouriteItem:(void (^)())success {
    PFRelation *relation = self.favourite;
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.maryFavouriteItem removeAllObjects];
            
            for (ItemData *iData in objects) {
                [self.maryFavouriteItem addObject:iData];
            }
        }
        
        success();
    }];
    
    [self getFollowingUser:nil];
}

- (void)getFollowingUser:(void (^)())success {
    // get following
    PFRelation *relation = self.following;
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.maryFollowingUser removeAllObjects];
            
            for (UserData *uData in objects) {
                [self.maryFollowingUser addObject:uData];
            }
            
            if (success) {
                success();
            }
        }
    }];
}

- (void)getFollowerUser:(void (^)())success {
    // get following
    PFRelation *relation = self.follower;
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.maryFollowerUser removeAllObjects];
            
            for (UserData *uData in objects) {
                [self.maryFollowerUser addObject:uData];
            }
            
            if (success) {
                success();
            }
        }
    }];
}


- (NSString *)getUsernameToShow {
    
    NSString *strName = self.username;
    
    if ((self.firstname && [self.firstname length] > 0) ||
        (self.lastname && [self.lastname length] > 0)) {
        strName = [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
    }
    
    return strName;
}

- (BOOL)isItemFavourite:(ItemData *)data {
    
    BOOL bExisting = NO;
    
    for (ItemData *iData in self.maryFavouriteItem) {
        if ([iData.objectId isEqualToString:data.objectId]) {
            bExisting = YES;
            break;
        }
    }
    return bExisting;
}

- (BOOL)isUserFollowing:(UserData *)data {
    
    BOOL bExisting = NO;
    
    for (UserData *uData in self.maryFollowingUser) {
        if ([uData.objectId isEqualToString:data.objectId]) {
            bExisting = YES;
            break;
        }
    }
    return bExisting;
}

- (void)doFollow:(UserData *)user {
    if ([self.objectId isEqualToString:user.objectId]) {
        return;
    }
    
    if ([self isUserFollowing:user]) {
        return;
    }
    
    [self.following addObject:user];
    [self saveInBackground];
    
    [PFCloud callFunctionInBackground:@"addMeAsFollower"
                       withParameters:@{@"userId":user.objectId}
                                block:^(id object, NSError *error)
     {
         if (error) {
             NSLog(@"%@", error);
         }
     }];
    
    // save to notification data
    NotificationData *notifyObj = [NotificationData object];
    notifyObj.user = self;
    notifyObj.username = [self getUsernameToShow];
    notifyObj.targetuser = user;
    notifyObj.type = NOTIFICATION_FOLLOW;
    [notifyObj saveInBackground];
    
    [self.maryFollowingUser addObject:user];
    
    UserData *currentUser = [UserData currentUser];
    
    //
    // send notification to follow
    //
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"user" equalTo:user];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%@ thinks you are a great person", [currentUser getUsernameToShow]], @"alert",
                          @"follow", @"notifyType",
                          user.objectId, @"notifyItem",
                          @"Increment", @"badge",
                          @"cheering.caf", @"sound",
                          nil];
    [push setData:data];
    
    [push sendPushInBackground];
}

- (void)doUnFollow:(UserData *)user {
    if ([self.objectId isEqualToString:user.objectId]) {
        return;
    }
    
    if (![self isUserFollowing:user]) {
        return;
    }
    
    [self.following removeObject:user];
    [self saveInBackground];
    
    [PFCloud callFunctionInBackground:@"removeMeAsFollower"
                       withParameters:@{@"userId":user.objectId}
                                block:^(id object, NSError *error)
     {
         if (error) {
             NSLog(@"%@", error);
         }
     }];
    
    for (UserData *uData in self.maryFollowingUser) {
        if ([uData.objectId isEqualToString:user.objectId]) {
            [self.maryFollowingUser removeObject:uData];
            break;
        }
    }
}



@end
