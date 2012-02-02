//
//  Complain.h
//  HelloSarkar
//
//  Created by Samesh Swongamika on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Complain : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * complainText;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * serverID;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * sendDate;
@property (nonatomic, retain) NSString * complaintype;
@property (nonatomic, retain) NSString * district;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * districtCode;
@property (nonatomic, retain) NSString * complainTypeCode;

@end
