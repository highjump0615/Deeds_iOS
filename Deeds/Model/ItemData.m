//
//  ItemData.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "ItemData.h"

@implementation ItemData

@dynamic user;
@dynamic username;
@dynamic title;
@dynamic desc;
@dynamic address;
@dynamic category;
@dynamic images;
@dynamic type;
@dynamic location;
@dynamic commentobject;
@dynamic reportcount;
@dynamic done;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Item";
}


@end
