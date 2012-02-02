//
//  DistrictViewController.m
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DistrictViewController.h"

@implementation DistrictViewController

@synthesize districtListTableView;
@synthesize districtCodeListArray;
@synthesize districtListArray;
@synthesize selectedIndex;
@synthesize selectedDistrictCode;
@synthesize connectionGetDistrictList;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [SharedStore store].districtArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"districtArray"];
        responseDataGetDistrictList = [[NSMutableData data] retain];
        districtCodeListArray =[[NSMutableArray alloc] init];
        districtListArray =[[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initWithDistrictCode:(NSString *)_distrcitCode{
    if((self = [super init])){
        // Custom initialization
        [SharedStore store].districtArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"districtArray"];
        responseDataGetDistrictList = [[NSMutableData data] retain];
        districtCodeListArray =[[NSMutableArray alloc] init];
        districtListArray =[[NSMutableArray alloc] init];
        selectedDistrictCode = _distrcitCode;
	}
	return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	districtListTableView.backgroundColor = [UIColor clearColor];

//    if ([SharedStore store].districtArray.count == 0) {
//        [self getDistrictListFromServer];        
//    }
//    else
//    {
//        [self prepareDistrictList];        
//    }
    
    [self prepareDistrictList];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    return [districtListArray count];
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
    cell.textLabel.text = (NSString *)[districtListArray objectAtIndex:indexPath.row];
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
    [delegate selectedDistrct:[districtListArray objectAtIndex:indexPath.row] withCode:[districtCodeListArray objectAtIndex:indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)getDistrictListFromServer{
    NSString *connectionString = [NSString stringWithFormat:@"%@/hellosarkar/data/district.xml", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"GET"];
	connectionGetDistrictList = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	if (connectionGetDistrictList) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}	
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
    [responseDataGetDistrictList setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseDataGetDistrictList appendData:data];                
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {		
    self.connectionGetDistrictList = nil;
	NSLog(@"connection didFailWithError ------------");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *responseStringGetDistrictList = [[[NSString alloc] initWithData:responseDataGetDistrictList encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"responseStringGetDistrictList STRING -->%@\n", responseStringGetDistrictList);

    NSDictionary *responseDictionary = [[NSDictionary alloc] init];
    NSError *error;
    responseDictionary = [XMLReader dictionaryForXMLString:responseStringGetDistrictList error:&error];
    
    [SharedStore store].districtArray = (NSMutableArray *)[[responseDictionary valueForKey:@"districts"] valueForKey:@"district"];
    
    if ([[SharedStore store].districtArray count] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[SharedStore store].districtArray forKey:@"districtArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self prepareDistrictList];
        [self.districtListTableView reloadData];
    }
    else
    {
        [self showListNotFoundAlertView];
        [SharedStore store].districtArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"districtArray"];
    }
         
    self.connectionGetDistrictList = nil;    
}

#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------
-(void)prepareDistrictList{    
    NSDictionary *districtDictionary = [[[NSDictionary alloc] init] autorelease];
    for (int i = 0; i < [SharedStore store].districtArray.count; i++) {
        districtDictionary = (NSDictionary *)[[SharedStore store].districtArray objectAtIndex:i];
        
        [districtCodeListArray addObject:[districtDictionary valueForKey:@"code"]];
        [districtListArray addObject:[districtDictionary valueForKey:@"text"]];
    }    
    
    // DUMMY DATA
    [districtCodeListArray addObjectsFromArray:[NSArray arrayWithObjects:@"BKT", @"KTM", @"LTP", nil]];
    [districtListArray addObjectsFromArray:[NSArray arrayWithObjects:@"Bhaktapur", @"Kathmandu", @"Lalitpur", nil]];
    NSLog(@"COde --> %@", districtCodeListArray);
    NSLog(@"DISTRICTS --> %@", districtListArray);
    
    selectedIndex = [districtCodeListArray indexOfObject:selectedDistrictCode];
    if (!(selectedIndex >= 0)) {
        [delegate selectedDistrct:@"" withCode:@""];
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
    [districtListTableView release];
    [districtCodeListArray release];
    [districtListArray release];
    [responseDataGetDistrictList release];
//    [selectedDistrictCode release];
    
    [super dealloc];
}

@end
