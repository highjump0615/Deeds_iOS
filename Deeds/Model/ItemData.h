//
//  ItemData.h
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@class CategoryData;
@class UserData;

typedef enum {
    ITEMTYPE_DEED = 0,
    ITEMTYPE_INNEED,
} ItemType;


@interface ItemData : PFObject <PFSubclassing>

@property (nonatomic, retain) UserData *user;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) CategoryData *category;
@property (nonatomic) ItemType type;
@property (nonatomic, retain) PFGeoPoint *location;
@property (nonatomic, retain) PFRelation *commentobject;
@property (nonatomic, retain) NSNumber *reportcount;
@property (nonatomic, retain) NSNumber *done;

@end
