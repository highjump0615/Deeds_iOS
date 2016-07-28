//
//  GeneralData.h
//  Deeds
//
//  Created by highjump on 15-5-20.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GeneralData : PFObject <PFSubclassing>

@property (nonatomic, retain) NSNumber *itemcount;
@property (nonatomic, retain) NSNumber *itemdone;

@end
