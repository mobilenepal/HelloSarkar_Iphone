//
//  HelloSarkarAppDelegate.h
//  HelloSarkar
//
//  Created by nepal on 26/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComplainViewController.h"
#import "ComplaintBoxViewController.h"

@interface HelloSarkarAppDelegate : NSObject <UIApplicationDelegate>{
    UITabBarController *tabBarController;
}

//---------  PROPERTIES --------- 
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//---------  SELF METHODS ---------
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//---------  CUSTOM METHODS ---------
-(void)loadTabs;


@end
