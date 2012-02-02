//
//  ComplainViewController.h
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SharedStore.h"
#import "XMLReader.h"
#import "Complain.h"
#import "EditFieldCell.h"
#import "DistrictViewController.h"
#import "ComplainTypeViewController.h"

@interface ComplainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,  UITextViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, EditFieldCellDelegate, DistrictViewControllerDelegate, ComplainTypeViewControllerDelegate>{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITableView *complainsTableView;
    IBOutlet UITextView *complainTextView;
    IBOutlet UIButton *reportBUtton;
    UIDatePicker *datePickerView;
    
    NSInteger actionMode;
    
    NSInteger complain_ID;
    NSString *complain_serverID;
    NSString *complain_name;
    NSString *complain_district;
    NSString *complain_districtCode;
    NSString *complain_address;
    NSString *complain_mobile;
    NSString *complain_complaintype;
    NSString *complain_complainTypeCode;
    NSDate *complain_sendDate;
    NSString *complain_latitude;
    NSString *complain_longitude;
    NSString *complain_complainText;
    NSString *complain_status; 
    
    NSURLConnection *connectionSendComplain, *connectionCheckComplainStatus;
	NSMutableData *responseDataSendComplain, *responseDataCheckComplainStatus;

    NSManagedObjectContext *managedObjectContext;
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITableView *complainsTableView;
@property(nonatomic,retain) IBOutlet UITextView *complainTextView;
@property(nonatomic,retain) IBOutlet UIDatePicker *datePickerView;
@property(nonatomic,assign) NSInteger complain_ID;
@property(nonatomic,retain) NSString *complain_serverID;
@property(nonatomic,retain) NSString *complain_name;
@property(nonatomic,retain) NSString *complain_district;
@property(nonatomic,retain) NSString *complain_districtCode;
@property(nonatomic,retain) NSString *complain_address;
@property(nonatomic,retain) NSString *complain_mobile;
@property(nonatomic,retain) NSString *complain_complaintype;
@property(nonatomic,retain) NSString *complain_complainTypeCode;
@property(nonatomic,retain) NSDate *complain_sendDate;
@property(nonatomic,retain) NSString *complain_latitude;
@property(nonatomic,retain) NSString *complain_longitude;
@property(nonatomic,retain) NSString *complain_complainText;
@property(nonatomic,retain) NSString *complain_status;
@property(nonatomic,retain) NSURLConnection *connectionSendComplain;
@property(nonatomic,retain) NSURLConnection *connectionCheckComplainStatus;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//---------  SELF METHODS ---------
-(id)initWithComplain:(Complain *)_complain inMode:(NSInteger)mode;

//---------  IBACTION METHODS --------- 
-(IBAction)sendComplainButtonClicked:(id)sender;

//---------  URLCONNECTION METHODS --------- 
-(void)sendComplainToServer;
-(void)checkComplainStatus;

//---------  CUSTOM METHODS ---------
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)loadInitialvalues;
-(void)fillDate:(EditFieldCell *)cell;
-(void)saveComplainValues;
-(void)resetScrollContent;
-(void)relocateScrollViewBounds:(NSInteger)tag;
-(void)showDistrictList;
-(void)showComplainTypeList;
-(void)showDatePicker;
-(void)showResendAlerView;
-(void)showStatusCheckFailedAlertView;
-(BOOL)validateData;
-(void)saveComplainInDB;
-(void)updateComplainInDB;
-(void)deleteComplainFromDB;
-(void)updateDB;

@end
