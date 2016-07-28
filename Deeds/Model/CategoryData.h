//
//  CategoryData.h
//  Deeds
//
//  Created by highjump on 15-5-21.
//
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>


@interface CategoryData : PFObject <PFSubclassing>

@property (nonatomic, retain) NSString *name;

@end
