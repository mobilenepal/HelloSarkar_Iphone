//
//  EditFieldCell.m
//  TableEdit
//
//  Created by IphoneMac on 1/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditFieldCell.h"


@implementation EditFieldCell

@synthesize fieldLabel;
@synthesize textField;
@synthesize delegate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark -
#pragma mark ---------- UITEXTFIELD DELEGATE METHODS ----------

- (void)textFieldDidBeginEditing:(UITextField *)tf {
	[delegate textFieldSelected];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {		
    self.textField.userInteractionEnabled = NO;
	[self.textField resignFirstResponder];
	[delegate textFieldResinged:self.textField.tag withText:self.textField.text];
	
    return NO;
}


#pragma mark -
#pragma mark ---------- CUSTOM METHODS ----------

-(void)assignAsFirstResponder{
    self.textField.userInteractionEnabled = YES;
    [self.textField becomeFirstResponder];
}

- (void)dealloc {  
    [fieldLabel release];
    [textField release];
    [super dealloc];  
}  


@end
