//
//  SharedStore.h
//  YouSpin
//
//  Created by nepal on 10/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_STRING @"http://apps.mobilenepal.net"
#define STATUS_UNREPORTED @"unreported"
#define STATUS_REPORTED @"reported" 
#define STATUS_RESOLVED @"problem resolved" 

#define COMPLAIN_CREATING 0
#define COMPLAIN_EDITING 1
#define COMPLAIN_REPORTED 2
#define COMPLAIN_RESOLVED 3

@interface SharedStore : NSObject{
	UIColor *backColorForViews;
    UIColor *navigationBarColor;
    
    NSMutableArray *districtArray;
    NSMutableArray *complainTypeArray;    
}
+(SharedStore*)store;

//---------  PROPERTIES ---------
@property (nonatomic, retain) UIColor *backColorForViews;
@property (nonatomic, retain) UIColor *navigationBarColor;
@property (nonatomic, retain) NSMutableArray *districtArray;
@property (nonatomic, retain) NSMutableArray *complainTypeArray;

//---------  CUSTOM METHODS ---------


@end
