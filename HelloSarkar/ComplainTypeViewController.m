//
//  ComplainTypeViewController.m
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComplainTypeViewController.h"

@implementation ComplainTypeViewController

@synthesize complainTypeListTableView;
@synthesize complainTypeCodeListArray;
@synthesize complainTypeListArray;
@synthesize selectedIndex;
@synthesize selectedComplainTypeCode;
@synthesize connectionGetComplainTypeList;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [SharedStore store].complainTypeArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"complainTypeArray"];
        responseDataGetComplainTypeList = [[NSMutableData data] retain];
        complainTypeCodeListArray =[[NSMutableArray alloc] init];
        complainTypeListArray =[[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithComplainTypeCode:(NSString *)_complainTypeCode{
    if((self = [super init])){
        // Custom initialization
        [SharedStore store].complainTypeArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"complainTypeArray"];
        responseDataGetComplainTypeList = [[NSMutableData data] retain];
        complainTypeCodeListArray =[[NSMutableArray alloc] init];
        complainTypeListArray =[[NSMutableArray alloc] init];
        selectedComplainTypeCode = _complainTypeCode;
	}
	return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	complainTypeListTableView.backgroundColor = [UIColor clearColor];

//    if ([SharedStore store].complainTypeArray.count == 0) {
//        [self getComplainTypeFromServer];        
//    }
//    else
//    {
//        [self prepareComplainTypeList];        
//    }
    
    [self prepareComplainTypeList];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    return [complainTypeListArray count];
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
    
	return cell;
}

// Configure CELL
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;   
    cell.textLabel.text = (NSString *)[complainTypeListArray objectAtIndex:indexPath.row];
    if (indexPath.row == selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (selectedIndex >= 0) {
        NSIndexPath *formalIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        cell = [tableView cellForRowAtIndexPath:formalIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    selectedIndex = indexPath.row;
    cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [delegate selectedComplainType:[complainTypeListArray objectAtIndex:indexPath.row] withCode:[complainTypeCodeListArray objectAtIndex:indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)getComplainTypeFromServer{
    NSString *connectionString = [NSString stringWithFormat:@"%@/hellosarkar/data/categories.xml", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"GET"];
	connectionGetComplainTypeList = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionGetComplainTypeList) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}	   
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
    [responseDataGetComplainTypeList setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseDataGetComplainTypeList appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {		
    self.connectionGetComplainTypeList = nil;
	NSLog(@"connection didFailWithError ------------");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *responseStringGetComplainTypeList = [[[NSString alloc] initWithData:responseDataGetComplainTypeList encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"responseStringGetComplainTypeList STRING -->%@\n", responseStringGetComplainTypeList);
    
    NSDictionary *responseDictionary = [[NSDictionary alloc] init];
    NSError *error;
    responseDictionary = [XMLReader dictionaryForXMLString:responseStringGetComplainTypeList error:&error];
    
    [SharedStore store].complainTypeArray = (NSMutableArray *)[[responseDictionary valueForKey:@"categories"] valueForKey:@"category"];
    
    if ([[SharedStore store].complainTypeArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].complainTypeArray forKey:@"complainTypeArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self prepareComplainTypeList];
        [self.complainTypeListTableView reloadData];
    }
    else
    {
        [self showListNotFoundAlertView];
        [SharedStore store].complainTypeArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"complainTypeArray"];
    }
    
    self.connectionGetComplainTypeList = nil;
}


#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------
-(void)prepareComplainTypeList {    
    NSDictionary *complainTypeDictionary = [[[NSDictionary alloc] init] autorelease];
    for (int i = 0; i < [SharedStore store].complainTypeArray.count; i++) {
        complainTypeDictionary = (NSDictionary *)[[SharedStore store].complainTypeArray objectAtIndex:i];
        
        [complainTypeListArray addObject:[complainTypeDictionary valueForKey:@"text"]];
        [complainTypeCodeListArray addObject:[complainTypeDictionary valueForKey:@"code"]];
    }    
    
    // DUMMY DATA
    [complainTypeListArray addObjectsFromArray:[NSArray arrayWithObjects:@"General", @"Robbery", @"Thuggery", nil]];
    [complainTypeCodeListArray addObjectsFromArray:[NSArray arrayWithObjects:@"Gn", @"Rob", @"Tug", nil]];

    NSLog(@"COMPLAIN TYPES --> %@", complainTypeListArray);
    NSLog(@"COMPLAIN TYPES --> %@", complainTypeCodeListArray);
    
    selectedIndex = [complainTypeCodeListArray indexOfObject:selectedComplainTypeCode];
    if (!(selectedIndex >= 0)) {
        [delegate selectedComplainType:@"" withCode:@""];
    }
}

-(void)showListNotFoundAlertView{
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    [alert setTitle:@"Error!!"];
    [alert setMessage:@"Couldn't update the list"];
    [alert addButtonWithTitle:@"OK"];
    [alert setDelegate:nil];
    [alert show];
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
    [complainTypeListTableView release];
    [complainTypeCodeListArray release];
    [complainTypeListArray release];
    [responseDataGetComplainTypeList release];
//    [selectedComplainTypeCode release];
    [super dealloc];
}
@end
