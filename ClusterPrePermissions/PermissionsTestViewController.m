//
//  PermissionsTestViewController.m
//  ClusterPrePermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "PermissionsTestViewController.h"

#import "ClusterPrePermissions.h"

@interface PermissionsTestViewController ()
@property (strong, nonatomic) IBOutlet UILabel *photoPermissionResultLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactsPermissionResultLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationPermissionResultLabel;

@end

@implementation PermissionsTestViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPhotoPermissionsButtonTapped:(id)sender
{
    ClusterPrePermissions *permissions = [ClusterPrePermissions sharedPermissions];
    [permissions showPhotoPermissionsWithTitle:@"Access your photos?"
                                       message:@"Your message here"
                               denyButtonTitle:@"Not Now"
                              grantButtonTitle:@"Give Access"
                             completionHandler:^(BOOL hasPermission,
                                                 ClusterDialogResult userDialogResult,
                                                 ClusterDialogResult systemDialogResult) {
                                 [self updateResultLabel:self.photoPermissionResultLabel
                                          withPermission:hasPermission
                                        userDialogResult:userDialogResult
                                      systemDialogResult:systemDialogResult];
                             }];
}

- (IBAction)onContactsButtonPermissionTapped:(id)sender
{
    ClusterPrePermissions *permissions = [ClusterPrePermissions sharedPermissions];
    [permissions showContactsPermissionsWithTitle:@"Access your contacts?"
                                          message:@"Your message here"
                                  denyButtonTitle:@"Not Now"
                                 grantButtonTitle:@"Give Access"
                                completionHandler:^(BOOL hasPermission,
                                                    ClusterDialogResult userDialogResult,
                                                    ClusterDialogResult systemDialogResult) {
                                    [self updateResultLabel:self.contactsPermissionResultLabel
                                             withPermission:hasPermission
                                           userDialogResult:userDialogResult
                                         systemDialogResult:systemDialogResult];
                                }];
}

- (IBAction)onLocationButtonPermissionTapped:(id)sender
{
    ClusterPrePermissions *permissions = [ClusterPrePermissions sharedPermissions];
    [permissions showLocationPermissionsWithTitle:@"Access your location?"
                                          message:@"Your message here"
                                  denyButtonTitle:@"Not Now"
                                 grantButtonTitle:@"Give Access"
                                completionHandler:^(BOOL hasPermission,
                                                    ClusterDialogResult userDialogResult,
                                                    ClusterDialogResult systemDialogResult) {
                                    [self updateResultLabel:self.locationPermissionResultLabel
                                             withPermission:hasPermission
                                           userDialogResult:userDialogResult
                                         systemDialogResult:systemDialogResult];
                                }];
}


- (void) updateResultLabel:(UILabel *)resultLabel
            withPermission:(BOOL)hasPermission
          userDialogResult:(ClusterDialogResult)userDialogResult
        systemDialogResult:(ClusterDialogResult)systemDialogResult
{
    resultLabel.text = @"haha";
    resultLabel.alpha = 0.0;

    if (hasPermission) {
        resultLabel.textColor = [UIColor colorWithRed:0.1 green:1.0 blue:0.1 alpha:1.0];
    } else {
        resultLabel.textColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:1.0];
    }
    NSString *text = nil;
    if (userDialogResult == ClusterDialogResultNoActionTaken &&
        systemDialogResult == ClusterDialogResultNoActionTaken) {
        NSString *prefix = nil;
        if (hasPermission) {
            prefix = @"Granted.";
        } else if (systemDialogResult == ClusterDialogResultParentallyRestricted) {
            prefix = @"Restricted.";
        } else {
            prefix = @"Denied.";
        }
        text = [NSString stringWithFormat:@"%@ Dialogs not shown, system choice already made.", prefix];
    } else {
        NSString *userResultString = [self stringFromDialogResult:userDialogResult];
        NSString *systemResultString = [self stringFromDialogResult:systemDialogResult];
        text = [NSString stringWithFormat:@"User Action: %@\nSystem Action: %@", userResultString, systemResultString];
    }
    resultLabel.text = text;

    [UIView animateWithDuration:0.35 animations:^{
        resultLabel.alpha = 1.0;
    }];
}

- (NSString *) stringFromDialogResult:(ClusterDialogResult)result
{
    switch (result) {
        case ClusterDialogResultNoActionTaken:
            return @"No Action Taken";
            break;
        case ClusterDialogResultGranted:
            return @"Granted";
            break;
        case ClusterDialogResultDenied:
            return @"Denied";
            break;
        case ClusterDialogResultParentallyRestricted:
            return @"Restricted";
            break;
        default:
            break;
    }
}
@end
