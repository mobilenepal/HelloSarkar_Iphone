//
//  ComplaintBoxViewController.h
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelloSarkarAppDelegate.h"
#import "SharedStore.h"
#import "Complain.h"
#import "ComplainViewController.h"

@interface ComplaintBoxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate>{
    IBOutlet UITableView *complaintBoxTableView;
    IBOutlet UISegmentedControl *tableSegmentedControl;
    
    NSFetchedResultsController *fetchedResultsController;
    
    NSManagedObjectContext *managedObjectContext;
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UITableView *complaintBoxTableView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *tableSegmentedControl;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

//---------  IBACTION METHODS --------- 
-(IBAction)segmentedControlClicked:(id)sender;

//---------  URLCONNECTION METHODS --------- 

//---------  CUSTOM METHODS ---------
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
-(void)LoadTableForSegment;

@end
