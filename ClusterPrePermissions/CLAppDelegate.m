//
//  CLAppDelegate.m
//  ClusterPrePermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLAppDelegate.h"

#import "PermissionsTestViewController.h"

@implementation CLAppDelegate

+(void) initialize
{
    //This user default flag will allow us to check if we've asked for push notification permissions
    NSDictionary *pushNotificationFlag = @{@"pushNotification" : [NSNumber numberWithBool:false]};
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:pushNotificationFlag ];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[PermissionsTestViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)application:(UIApplication*) application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    bool pushNotification = [[NSUserDefaults standardUserDefaults] boolForKey:@"pushNotification"];
    if(!pushNotification) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pushNotification"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //Register device token stuff with whatever push notification system you're using
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //Handle information from remote notification here
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
