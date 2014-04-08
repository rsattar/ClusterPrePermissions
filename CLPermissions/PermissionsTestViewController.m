//
//  PermissionsTestViewController.m
//  CLPermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "PermissionsTestViewController.h"

#import "CLPermissions.h"

@interface PermissionsTestViewController ()
@property (strong, nonatomic) IBOutlet UILabel *photoPermissionResultLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactsPermissionResultLabel;

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
    [[CLPermissions sharedPermissions] requestPhotoPermissionsIfNeededWithRequestTitle:nil
                                                                               message:@"We'll never upload without your permission"
                                                                       denyButtonTitle:nil
                                                                      grantButtonTitle:nil
                                                                     completionHandler:^(BOOL hasPermission,
                                                                                         CLDialogResult userDialogResult,
                                                                                         CLDialogResult systemDialogResult) {
                                                                         [self updateResultLabel:self.photoPermissionResultLabel
                                                                                  withPermission:hasPermission
                                                                                userDialogResult:userDialogResult
                                                                              systemDialogResult:systemDialogResult];
                                                                     }];
}

- (IBAction)onContactsButtonPermissionTapped:(id)sender
{
    [[CLPermissions sharedPermissions] requestContactsPermissionsIfNeededWithRequestTitle:nil
                                                                                  message:@"It makes inviting friends easier"
                                                                          denyButtonTitle:nil
                                                                         grantButtonTitle:nil
                                                                        completionHandler:^(BOOL hasPermission,
                                                                                            CLDialogResult userDialogResult,
                                                                                            CLDialogResult systemDialogResult) {
                                                                            [self updateResultLabel:self.contactsPermissionResultLabel
                                                                                     withPermission:hasPermission
                                                                                   userDialogResult:userDialogResult
                                                                                 systemDialogResult:systemDialogResult];
                                                                        }];
}

- (void) updateResultLabel:(UILabel *)resultLabel
            withPermission:(BOOL)hasPermission
          userDialogResult:(CLDialogResult)userDialogResult
        systemDialogResult:(CLDialogResult)systemDialogResult
{
    resultLabel.text = @"haha";
    resultLabel.alpha = 0.0;

    if (hasPermission) {
        resultLabel.textColor = [UIColor colorWithRed:0.1 green:1.0 blue:0.1 alpha:1.0];
    } else {
        resultLabel.textColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:1.0];
    }
    NSString *text = nil;
    if (userDialogResult == CLDialogResultNoActionTaken &&
        systemDialogResult == CLDialogResultNoActionTaken) {
        NSString *prefix = nil;
        if (hasPermission) {
            prefix = @"Granted.";
        } else if (systemDialogResult == CLDialogResultParentallyRestricted) {
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

- (NSString *) stringFromDialogResult:(CLDialogResult)result
{
    switch (result) {
        case CLDialogResultNoActionTaken:
            return @"No Action Taken";
            break;
        case CLDialogResultGranted:
            return @"Granted";
            break;
        case CLDialogResultDenied:
            return @"Denied";
            break;
        case CLDialogResultParentallyRestricted:
            return @"Restricted";
            break;
        default:
            break;
    }
}
@end
