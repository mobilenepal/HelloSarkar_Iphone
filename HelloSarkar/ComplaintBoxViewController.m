//
//  ComplaintBoxViewController.m
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComplaintBoxViewController.h"

@implementation ComplaintBoxViewController

@synthesize complaintBoxTableView;
@synthesize tableSegmentedControl;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    tableSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBezeled;
    tableSegmentedControl.tintColor = [SharedStore store].navigationBarColor;
    
    complaintBoxTableView.backgroundColor = [UIColor clearColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//
#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(IBAction)segmentedControlClicked:(id)sender{
    [self LoadTableForSegment];
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell..
    [self configureCell:cell atIndexPath:indexPath];    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
	return cell;
}

// Configure CELL
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    Complain *complain = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = complain.complainText;
    cell.detailTextLabel.text = complain.complaintype;
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [complain.ID intValue]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Complain *complain = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSInteger mode;
    
    if (tableSegmentedControl.selectedSegmentIndex == 0) {
    // UN-REPORTED
        mode = COMPLAIN_EDITING;
    }
    else if (tableSegmentedControl.selectedSegmentIndex == 1) {
        if ([complain.status isEqualToString:STATUS_REPORTED]) {
            // REPORTED
            mode = COMPLAIN_REPORTED;                    
        }
        else if ([complain.status isEqualToString:STATUS_RESOLVED]) {
            // RESOLVED
            mode = COMPLAIN_RESOLVED;            
        }
    }
    NSLog(@"CELL OBJECT ------------------------");
    NSLog(@"COMPLAIN ------> %@", complain);
    ComplainViewController *complainViewController = [[[ComplainViewController alloc] initWithComplain:complain inMode:mode] autorelease];
    complainViewController.title = @"Complain";
    complainViewController.managedObjectContext = ((HelloSarkarAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;	
    [self.navigationController pushViewController:complainViewController animated:YES];
}

#pragma mark -
#pragma mark ---------- FETCHEDRESULTSCONTROLER delegate methods ----------

//override fetchedResultsController getter
- (NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController == nil) {		
		NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Complain" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setFetchBatchSize:20];
		[fetchRequest setEntity:entity];
        
        NSPredicate *predicate;
        if (tableSegmentedControl.selectedSegmentIndex == 0) {
            predicate = [NSPredicate predicateWithFormat:@"status = %@", STATUS_UNREPORTED];            
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"status = %@", STATUS_REPORTED];
        }
        [fetchRequest setPredicate:predicate];
                
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"ID" ascending:YES] autorelease];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
		fetchedResultsController.delegate = self;
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error]) {
			//handle the error...
			NSLog(@"error occured in fetched result controller");
		}
	}	
	return fetchedResultsController;
}  

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.complaintBoxTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.complaintBoxTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.complaintBoxTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath 
	 forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	switch(type) {
		case NSFetchedResultsChangeUpdate:
			[self configureCell:(UITableViewCell *)[self.complaintBoxTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[self.complaintBoxTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.complaintBoxTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeInsert:
			[self.complaintBoxTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationRight];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.complaintBoxTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.complaintBoxTableView endUpdates];
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)LoadTableForSegment{
//    if (tableSegmentedControl.selectedSegmentIndex == 0) {
//        
//    }
    self.fetchedResultsController = nil;
    [complaintBoxTableView reloadData];
}

#pragma mark - 
#pragma mark ---------- MEMORY MANAGEMENT ----------
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [complaintBoxTableView release];
    [tableSegmentedControl release];
    [fetchedResultsController release];
    [managedObjectContext release];
    [super dealloc];
}


@end
