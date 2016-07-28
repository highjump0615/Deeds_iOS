//
//  GeneralData.m
//  Deeds
//
//  Created by highjump on 15-5-20.
//
//

#import "GeneralData.h"

@implementation GeneralData

@dynamic itemcount;
@dynamic itemdone;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"General";
}


@end
