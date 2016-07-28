//
//  UserData.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class ItemData;

@interface UserData : PFUser <PFSubclassing>

@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *about;
@property (nonatomic, retain) PFFile *photo;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) PFGeoPoint *location;
@property (nonatomic, retain) PFRelation *favourite;
@property (nonatomic, retain) PFRelation *follower;
@property (nonatomic, retain) PFRelation *following;
@property (nonatomic, retain) PFRelation *review;
//@property (nonatomic, retain) NSNumber *reviewcount;

@property (nonatomic, retain) NSMutableArray *maryFavouriteItem;

@property (nonatomic, retain) NSMutableArray *maryFollowingUser;
@property (nonatomic, retain) NSMutableArray *maryFollowerUser;
@property (nonatomic, retain) NSMutableArray *maryReview;

@property (nonatomic) NSInteger mnReviewCount;


- (NSString *)getUsernameToShow;

- (void)getFavouriteItem:(void (^)())success;
- (BOOL)isItemFavourite:(ItemData *)data;

- (BOOL)isUserFollowing:(UserData *)data;
- (void)doFollow:(UserData *)user;
- (void)doUnFollow:(UserData *)user;

- (void)getFollowingUser:(void (^)())success;
- (void)getFollowerUser:(void (^)())success;

@end
