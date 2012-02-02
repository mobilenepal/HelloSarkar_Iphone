//
//  ComplainViewController.m
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComplainViewController.h"

@implementation ComplainViewController

@synthesize scrollView;
@synthesize complainsTableView;
@synthesize datePickerView;
@synthesize complain_ID;
@synthesize complain_serverID;
@synthesize complain_name;
@synthesize complain_district;
@synthesize complain_districtCode;
@synthesize complain_address;
@synthesize complain_mobile;
@synthesize complain_complaintype;
@synthesize complain_complainTypeCode;
@synthesize complain_sendDate;
@synthesize complain_latitude;
@synthesize complain_longitude;
@synthesize complain_complainText;
@synthesize complain_status;
@synthesize complainTextView;
@synthesize connectionSendComplain, connectionCheckComplainStatus;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        actionMode = COMPLAIN_CREATING;
        responseDataSendComplain = [[NSMutableData data] retain];
        responseDataCheckComplainStatus = [[NSMutableData data] retain];
    }
    return self;
}

-(id)initWithComplain:(Complain *)_complain inMode:(NSInteger)mode{
	if((self = [super init])){
        // Custom initialization
        actionMode = mode;

        self.complain_ID = [_complain.ID intValue];
        self.complain_serverID = _complain.serverID;
        self.complain_name = _complain.name;
        self.complain_district = _complain.district;
        self.complain_districtCode = _complain.districtCode;
        self.complain_address = _complain.address;
        self.complain_mobile = _complain.mobile;
        self.complain_complaintype = _complain.complaintype;
        self.complain_complainTypeCode = _complain.complainTypeCode;
        self.complain_sendDate = [_complain.sendDate retain];
        self.complain_complainText = _complain.complainText;
        self.complain_latitude = _complain.latitude;
        self.complain_longitude = _complain.longitude;
        self.complain_status = _complain.status;
        
        responseDataSendComplain = [[NSMutableData data] retain];
        responseDataCheckComplainStatus = [[NSMutableData data] retain];
	}
	return self;
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad-------");
    [super viewDidLoad];    
    self.view.backgroundColor = [SharedStore store].backColorForViews;
    self.complainsTableView.backgroundColor = [UIColor clearColor];
    
    datePickerView = [[UIDatePicker alloc] init];
    datePickerView.datePickerMode = UIDatePickerModeDate;
    [datePickerView setFrame:CGRectMake(0, 85, 320, 216)];
    
    complainTextView.layer.borderWidth = 1.5f;
	complainTextView.layer.borderColor = [[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1] CGColor];
//	[complainTextView.layer setMasksToBounds:YES];
	[complainTextView.layer setCornerRadius:10.0];
    
    [self loadInitialvalues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark ---------- IBACTION METHODS ----------

-(void)sendComplainButtonClicked:(id)sender{
    [self saveComplainValues];
    
    if ([self validateData]) {
        if (actionMode == COMPLAIN_CREATING || actionMode == COMPLAIN_EDITING) {
            if (actionMode == COMPLAIN_CREATING) {
                [self saveComplainInDB];            
            }
            else if (actionMode == COMPLAIN_EDITING) {
                [self updateComplainInDB];
            }
            [self sendComplainToServer];                     
        }
        else if (actionMode == COMPLAIN_REPORTED){
            NSLog(@"COMPLAIN_REPORTED ------------------");
            [self checkComplainStatus];
        }
    }
}


#pragma mark -
#pragma mark ---------- UITABLEVIEW DELEGATE METHODS ----------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    return 6;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	EditFieldCell *cell = (EditFieldCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    if (cell == nil){  
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EditFieldCell" owner:nil options:nil];  
        for(id currentObject in topLevelObjects) {  
            if([currentObject isKindOfClass:[EditFieldCell class]]) {  
                cell = (EditFieldCell *) currentObject;  
                break;  
            }  
        }  
    }  
	
	// Next line is very important ...   
    // you have to set the delegate from the cell back to this class  
    [cell setDelegate:self];
    
	// Configure the cell..
    [self configureCell:cell atIndexPath:indexPath];
    
	return cell;
}

// Configure CELL
-(void)configureCell:(EditFieldCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
//    cell.textLabel.text = (NSString *)[districtListArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell.textField setFont:[UIFont systemFontOfSize:15]];
    cell.textField.tag = indexPath.row;
    
    if (indexPath.row == 0) {
        cell.fieldLabel.text = @"Name :";
        cell.textField.placeholder = @"NAME";
        cell.textField.text = self.complain_name;
        cell.textField.tag = 0;
    }
    else if (indexPath.row == 1) {
        cell.fieldLabel.text = @"District :";
        cell.textField.placeholder = @"DISTRICT";
        cell.textField.text =self.complain_district;
        cell.textField.tag = 1;
    }
    else if (indexPath.row == 2) {
        cell.fieldLabel.text = @"Address :";
        cell.textField.placeholder = @"ADDRESS";
        cell.textField.text =self.complain_address;
        cell.textField.tag = 2;
    }
    else if (indexPath.row == 3) {
        cell.fieldLabel.text = @"Mobile :";
        cell.textField.placeholder = @"MOBILE";
        cell.textField.text =self.complain_mobile;
        cell.textField.tag = 3;
    }
    else if (indexPath.row == 4) {
        cell.fieldLabel.text = @"Complain :";
        cell.textField.placeholder = @"COMPLAIN CATEGORY";
        cell.textField.text = self.complain_complaintype;
        cell.textField.tag = 4;
    }
    else if (indexPath.row == 5) {
        cell.fieldLabel.text = @"Date :";
        cell.textField.placeholder = @"DATE";
        [self fillDate:cell];
        cell.textField.tag = 5;
    }
    
    if (indexPath.row == 1 || indexPath.row == 4) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 5) {
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    else {
        cell.userInteractionEnabled  = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    EditFieldCell *cell = (EditFieldCell *)[self.complainsTableView cellForRowAtIndexPath:indexPath];    
    if (indexPath.row == 1) {
        [self showDistrictList];
    }
    else if (indexPath.row == 4) {
        [self showComplainTypeList];
    }
    else if (indexPath.row == 5) {
        [self showDatePicker];
    }
    else {
        [cell assignAsFirstResponder];
    }

    // MAY BE WRONG IMPLEMENTATION BUT NECESSARY WORK AROUND
    [self saveComplainValues];
}

#pragma mark -
#pragma mark ---------- EDITFIELDCELL DELEGATE METHODS ----------

- (void)textFieldSelected
{
    [self relocateScrollViewBounds:0];
}

-(void)textFieldResinged:(NSInteger)tag withText:(NSString *)text
{
    [self resetScrollContent];
    
    if (tag == 0) {
        self.complain_name = text;
    }
    else if (tag == 2) {
        self.complain_address = text;        
    }
    else if (tag == 3) {
        self.complain_mobile = text;        
    }
}

#pragma mark -
#pragma mark ---------- UITEXTVIEW DELEGATE METHODS ----------

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([complain_complainText isEqualToString:@""]) {
        complainTextView.text = @"";
        complainTextView.textColor = [UIColor blackColor];        
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing");
    [self saveComplainValues];
    [self relocateScrollViewBounds:textView.tag];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    NSLog(@"shouldChangeTextInRange");
    self.complain_complainText = complainTextView.text;
	if ( [ text isEqualToString: @"\n" ] ) {
		[ textView resignFirstResponder ];
        if ([textView.text isEqualToString:@""]) 
        {
            complainTextView.text = @"Type your complain here(Max 150 letters)";
            complainTextView.textColor = [UIColor lightGrayColor];
        }
        
        [self resetScrollContent];
		return NO;
	}

	return YES;
}

-(BOOL)textViewShouldReturn:(UITextView *)textView
{
    NSLog(@"textViewShouldReturn");
    [textView resignFirstResponder];
    [self resetScrollContent];    
    
    return YES;
}

#pragma mark -
#pragma mark ---------- UIACTIONSHEET DELEGATE METHODS ----------

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"ACTIONS HHET");
	if (buttonIndex == 0)
	{	
        self.complain_sendDate = [datePickerView date];    
        
        [self.complainsTableView reloadData];
    }
}

#pragma mark -
#pragma mark ---------- UIALERTVIEW DELEGATE METHODS ----------

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
        {
            [self deleteComplainFromDB];
        }
        
        if (actionMode == COMPLAIN_CREATING) {
            [self loadInitialvalues];
            [self.complainsTableView reloadData];            
        }
        else if (actionMode == COMPLAIN_EDITING) {
           	[self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark ---------- DistrictViewControllerDelegate DELEGATE METHODS ----------

-(void)selectedDistrct:(NSString *)districtName withCode:(NSString *)districtNameCode{
    self.complain_district = districtName;
    self.complain_districtCode = districtNameCode;
    
    [self.complainsTableView reloadData];
}

#pragma mark -
#pragma mark ---------- ComplainTypeViewControllerDelegate DELEGATE METHODS ----------

-(void)selectedComplainType:(NSString *)complainTypeTitle withCode:(NSString *)complainTypeTitleCode
{
    self.complain_complaintype = complainTypeTitle;
    self.complain_complainTypeCode = complainTypeTitleCode;
    
    [self.complainsTableView reloadData];
}

#pragma mark -
#pragma mark ---------- URLCONNECTION METHODS ----------

-(void)sendComplainToServer{
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [dateFormat stringFromDate:self.complain_sendDate];

    NSString *encodedname = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_name, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedDistrict = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_districtCode, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedAddress = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_address, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedMobile = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_mobile, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedComplainCode = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_complainTypeCode, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedDate = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)dateString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
	NSString *encodedComplainText = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_complainText, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    
	NSString *content = [NSString stringWithFormat: @"name=%@&district_id=%@&address=%@&mobile=%@&complain_type=%@&complain_text=%@&mobile_info=%@&gps=&date=%@", encodedname, encodedDistrict, encodedAddress, encodedMobile, encodedComplainCode, encodedComplainText, @"Iphone", encodedDate];
	[encodedname release];
	[encodedDistrict release];
	[encodedAddress release];
	[encodedMobile release];
	[encodedComplainCode release];
    [encodedDate release];
	[encodedComplainText release];
	
    NSLog(@"PAARAMS -> %@", content);    
    
	NSString *connectionString = [NSString stringWithFormat:@"%@/hellosarkar/public/complain/receive", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
	self.connectionSendComplain = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	if (connectionSendComplain) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

-(void)checkComplainStatus{
      NSString *encodedServerID = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.complain_serverID, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    
    NSString *content = [NSString stringWithFormat:@"response_code=%@", encodedServerID];
    [encodedServerID release];
    
    NSString *connectionString = [NSString stringWithFormat:@"%@/hellosarkar/public/complain/getStatus", SERVER_STRING];
	NSURL* url = [NSURL URLWithString:connectionString];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:[content dataUsingEncoding:NSUTF8StringEncoding]];
	self.connectionCheckComplainStatus = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	if (connectionCheckComplainStatus) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

#pragma mark -
#pragma mark ---------- NSURLCONNECTION DELEGATE METHODS ----------

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
    if (connection == connectionSendComplain) {
        [responseDataSendComplain setLength:0];        
    }
    else if (connection == connectionCheckComplainStatus) {
        [responseDataCheckComplainStatus setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == connectionSendComplain) {
        [responseDataSendComplain appendData:data];        
    }
    else if (connection == connectionCheckComplainStatus) {
        [responseDataCheckComplainStatus appendData:data];        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {		
	NSLog(@"connection didFailWithError ------------");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if (connection == connectionSendComplain) {
        self.connectionSendComplain = nil;     
        
        [self showResendAlerView];
    }
    else if (connection == connectionCheckComplainStatus) {
        self.connectionCheckComplainStatus = nil;

        [self showStatusCheckFailedAlertView];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (connection == connectionSendComplain) {
        self.connectionSendComplain = nil;        

        NSString *responseStringSendComplain = [[[NSString alloc] initWithData:responseDataSendComplain encoding:NSUTF8StringEncoding] autorelease];        
        NSLog(@"responseStringSendComplain STRING -->%@", responseStringSendComplain);

        if (responseStringSendComplain.length == 6) {
            self.complain_serverID = responseStringSendComplain;
            self.complain_status = STATUS_REPORTED;
            
            [self updateComplainInDB];

            if (actionMode == COMPLAIN_EDITING) {
                actionMode = COMPLAIN_REPORTED;
            }
        }
        else {
            [self showResendAlerView]; 
        }

        [self loadInitialvalues];
        [self.complainsTableView reloadData];        
    }
    else if (connection == connectionCheckComplainStatus) {
        self.connectionCheckComplainStatus = nil;

        NSString *responseStringCheckComplainStatus = [[[NSString alloc] initWithData:responseDataCheckComplainStatus encoding:NSUTF8StringEncoding] autorelease];        
        NSLog(@"responseStringSendComplain STRING -->%@", responseStringCheckComplainStatus);
        
        
        if ([responseStringCheckComplainStatus isEqualToString:STATUS_RESOLVED]) {
            self.complain_status = responseStringCheckComplainStatus;
            
            [self updateComplainInDB];

            actionMode = COMPLAIN_RESOLVED;
            [self loadInitialvalues];
        }
        else {
            [self showStatusCheckFailedAlertView];
        }
        
    }
}


#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)loadInitialvalues{
    if (actionMode == COMPLAIN_CREATING) 
    {
        self.complain_name = @"";
        self.complain_district = @"";
        self.complain_districtCode = @"";
        self.complain_address = @"";
        self.complain_mobile = @"";
        self.complain_complaintype = @"";
        self.complain_complainTypeCode = @"";
        self.complain_sendDate = [NSDate date];
        self.complain_latitude = @"85.34";
        self.complain_longitude = @"22.45";
        self.complain_complainText = @"";
        self.complain_status = STATUS_UNREPORTED;        
    }
    else if (actionMode == COMPLAIN_EDITING) {
        [reportBUtton setTitle:@"Report" forState:UIControlStateNormal];
    }
    else if (actionMode == COMPLAIN_REPORTED) {
        complainsTableView.userInteractionEnabled = NO;
        complainTextView.userInteractionEnabled  = NO;

        [reportBUtton setTitle:@"Check Status" forState:UIControlStateNormal];
    }
    else if (actionMode == COMPLAIN_RESOLVED) {
        complainsTableView.userInteractionEnabled = NO;
        complainTextView.userInteractionEnabled  = NO;

        reportBUtton.userInteractionEnabled = NO;
        [reportBUtton setTitle:STATUS_RESOLVED forState:UIControlStateNormal];
    }    
    
    complainTextView.text = self.complain_complainText;
    if ([self.complain_complainText isEqualToString:@""]) {
        complainTextView.text = @"Type your complain here(Max 150 letters)";
        complainTextView.textColor = [UIColor lightGrayColor];
    }
}

-(void)fillDate:(EditFieldCell *)cell{   
    NSDateFormatter *dateFormat = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormat setDateFormat:@"MMMM-dd-yyyy"];
    NSLog(@"DATE --> %@", self.complain_sendDate);
    NSString *dateString = [dateFormat stringFromDate:self.complain_sendDate];
    
    cell.textField.text = dateString;
}

-(void)saveComplainValues{
    EditFieldCell *cellForName = (EditFieldCell *)[self.complainsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    EditFieldCell *cellForAddress = (EditFieldCell *)[self.complainsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    EditFieldCell *cellForMobile = (EditFieldCell *)[self.complainsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    self.complain_name = cellForName.textField.text;
    self.complain_address = cellForAddress.textField.text;
    self.complain_mobile = cellForMobile.textField.text;
    self.complain_complainText = complainTextView.text;
}

-(void)resetScrollContent{
    scrollView.contentSize = CGSizeMake(320, 481);
}

-(void)relocateScrollViewBounds:(NSInteger)tag{
    scrollView.contentSize = CGSizeMake(320, 645);
    
	CGRect scrollBounds = scrollView.bounds;
    if (tag >= 0 && tag <=5) {
        scrollBounds.origin.y = 0;
    }
    else if(tag == 6){
        scrollBounds.origin.y = 180;
    }
    [scrollView scrollRectToVisible:scrollBounds animated:YES];
}

-(void)showDistrictList{
    DistrictViewController *districtViewController = [[[DistrictViewController alloc] initWithDistrictCode:self.complain_districtCode] autorelease];
    districtViewController.title = @"District List";
    districtViewController.delegate = self;
    [self.navigationController pushViewController:districtViewController animated:YES];
}

-(void)showComplainTypeList{
    ComplainTypeViewController *complainTypeViewController = [[[ComplainTypeViewController alloc] initWithComplainTypeCode:self.complain_complainTypeCode] autorelease];
    complainTypeViewController.title = @"Complain Categories";
    complainTypeViewController.delegate = self;
    [self.navigationController pushViewController:complainTypeViewController animated:YES];
}

-(void)showDatePicker{
    UIActionSheet *menu = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    
    // Add the picker
    [datePickerView setDate:self.complain_sendDate];
    [menu addSubview:datePickerView];
    [menu showInView:self.navigationController.tabBarController.view];        
    [menu setBounds:CGRectMake(0,0,320, 516)];
}

-(void)showResendAlerView{
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    [alert setTitle:@"Save complain"];
    [alert setMessage:@"Want to save this complain and report it later??"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setDelegate:self];
    [alert setTag:1];
    [alert show]; 
}

-(void)showStatusCheckFailedAlertView{
    UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
    [alert setTitle:@"Error!!"];
    [alert setMessage:@"Status check failed"];
    [alert addButtonWithTitle:@"Ok"];
    [alert setDelegate:nil];
    [alert setTag:1];
    [alert show];     
}

-(BOOL)validateData{
    BOOL dataValid = YES;
    
    if ([self.complain_name isEqualToString:@""] || [self.complain_district isEqualToString:@""] || [self.complain_districtCode isEqualToString:@""] || [self.complain_address isEqualToString:@""] || [self.complain_mobile isEqualToString:@""] || [self.complain_complaintype isEqualToString:@""] || [self.complain_complainTypeCode isEqualToString:@""] || [self.complain_complainText isEqualToString:@""] || [self.complain_complainText isEqualToString:@"Type your complain here(Max 150 letters)"]) {
        dataValid = NO;
        
        UIAlertView *alert = [[[UIAlertView alloc] init] autorelease];
        [alert setTitle:@"Data Invalid"];
        [alert setMessage:@"One or more field has invalid or null data"];
        [alert addButtonWithTitle:@"OK"];
        [alert setDelegate:nil];
        [alert show];
    }
    
    return dataValid;
}

-(void)saveComplainInDB
{
    Complain *complain;
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Complain" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *complains = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    complain = [NSEntityDescription insertNewObjectForEntityForName:@"Complain" inManagedObjectContext:self.managedObjectContext];
    self.complain_ID = complains.count + 1;

    complain.ID = [NSNumber numberWithInt:self.complain_ID];
    complain.name = self.complain_name;
    complain.district = self.complain_district;
    complain.districtCode = self.complain_districtCode;
    complain.address = self.complain_address;
    complain.mobile = self.complain_mobile;
    complain.complaintype = self.complain_complaintype;
    complain.complainTypeCode = self.complain_complainTypeCode;
    complain.sendDate = self.complain_sendDate;
    complain.latitude = self.complain_latitude;
    complain.longitude = self.complain_latitude;
    complain.complainText = self.complain_complainText;
    complain.status = self.complain_status;    
    complain.complainText = self.complain_complainText;
    complain.serverID = self.complain_serverID;
    complain.status = self.complain_status;
    
    [self updateDB];
    
    NSLog(@"COMPLAIN ------> %@", complain);
}

-(void)updateComplainInDB;{
    Complain *complain;
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Complain" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID = %d", self.complain_ID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *complains = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (complains.count > 0) {
        complain = [complains objectAtIndex:0];
    }
    complain.name = self.complain_name;
    complain.district = self.complain_district;
    complain.districtCode = self.complain_districtCode;
    complain.address = self.complain_address;
    complain.mobile = self.complain_mobile;
    complain.complaintype = self.complain_complaintype;
    complain.complainTypeCode = self.complain_complainTypeCode;
    complain.sendDate = self.complain_sendDate;
    complain.latitude = self.complain_latitude;
    complain.longitude = self.complain_latitude;
    complain.complainText = self.complain_complainText;
    complain.status = self.complain_status;    
    complain.complainText = self.complain_complainText;
    complain.serverID = self.complain_serverID;
    complain.status = self.complain_status;

    [self updateDB];
    
    NSLog(@"COMPLAIN ------> %@", complain);
}

-(void)deleteComplainFromDB{
    Complain *complain;
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Complain" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID = %d", self.complain_ID];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    
    NSArray *complains = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (complains.count > 0) {
        complain = [complains objectAtIndex:0];
    }

    [self.managedObjectContext deleteObject:complain];	
    [self updateDB];
}

-(void)updateDB{
	NSError *error = nil;
	if ([self.managedObjectContext save:&error]) {
	}
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
    [scrollView release];
    [complainsTableView release];
    [complainTextView release];
    [datePickerView release];
//    [complain_serverID release];
//    [complain_name release];
//    [complain_district release];
//    [complain_districtCode release];
//    [complain_address release];
//    [complain_mobile release];
//    [complain_complaintype release];
//    [complain_complainTypeCode release];
//    [complain_sendDate release];
//    [complain_latitude release];
//    [complain_longitude release];
//    [complain_complainText release];
//    [complain_status release];
    [responseDataSendComplain release];
    [managedObjectContext release];
    [super dealloc];
}
@end
