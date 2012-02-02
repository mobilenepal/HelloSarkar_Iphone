//
//  DistrictViewController.h
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedStore.h"
#import "XMLReader.h"


@class DistrictViewController;  

@protocol DistrictViewControllerDelegate <NSObject>
    // we will make one function mandatory to include
    -(void)selectedDistrct:(NSString *)districtName withCode:(NSString *)districtNameCode;
@end  

@interface DistrictViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    IBOutlet UITableView *districtListTableView;
    
    NSMutableArray *districtCodeListArray;
    NSMutableArray *districtListArray;
    NSInteger selectedIndex;
    NSString *selectedDistrictCode;
    
    NSURLConnection *connectionGetDistrictList;
	NSMutableData *responseDataGetDistrictList;

    id <DistrictViewControllerDelegate> delegate;
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UITableView *districtListTableView;
@property (nonatomic, retain) NSMutableArray *districtCodeListArray;
@property (nonatomic, retain) NSMutableArray *districtListArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, retain) NSString *selectedDistrictCode;
@property(nonatomic,retain) NSURLConnection *connectionGetDistrictList;
@property (nonatomic, assign) id <DistrictViewControllerDelegate> delegate;

//---------  SELF METHODS ---------
-(id)initWithDistrictCode:(NSString *)_distrcitCode;

//---------  URLCONNECTION METHODS --------- 
-(void)getDistrictListFromServer;

//---------  CUSTOM METHODS ---------
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)prepareDistrictList;
-(void)showListNotFoundAlertView;

@end
