//
//  NotificationData.m
//  Deeds
//
//  Created by highjump on 15-4-13.
//
//

#import "NotificationData.h"

@interface NotificationData()

@end


@implementation NotificationData

@dynamic type;
@dynamic item;
@dynamic user;
@dynamic username;
@dynamic targetuser;
@dynamic comment;
@dynamic rate;

@synthesize mbExpanded;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Notification";
}

- (id)init {
    self = [super init];
    
    self.mbExpanded = NO;
    
    return self;
}


@end
