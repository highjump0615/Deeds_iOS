//
//  CategoryData.m
//  Deeds
//
//  Created by highjump on 15-5-21.
//
//

#import "CategoryData.h"

@implementation CategoryData

@dynamic name;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Category";
}


@end
