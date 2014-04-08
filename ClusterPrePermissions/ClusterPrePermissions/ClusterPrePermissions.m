//
//  ClusterPrePermissions.m
//  ClusterPrePermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "ClusterPrePermissions.h"

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ClusterPrePermissions () <UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *prePhotoPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler photoPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preContactPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler contactPermissionCompletionHandler;

@end

static ClusterPrePermissions *__sharedInstance;

@implementation ClusterPrePermissions

+ (instancetype) sharedPermissions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[ClusterPrePermissions alloc] init];
    });
    return __sharedInstance;
}


#pragma mark - Photo Permissions Help

- (void) showPhotoPermissionsWithTitle:(NSString *)requestTitle
                               message:(NSString *)message
                       denyButtonTitle:(NSString *)denyButtonTitle
                      grantButtonTitle:(NSString *)grantButtonTitle
                     completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access Photos?";
    }
    if (denyButtonTitle.length == 0) {
        denyButtonTitle = @"Not Now";
    }
    if (grantButtonTitle.length == 0) {
        grantButtonTitle = @"Give Access";
    }
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusNotDetermined) {
        self.photoPermissionCompletionHandler = completionHandler;
        self.prePhotoPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                      message:message
                                                                     delegate:self
                                                            cancelButtonTitle:denyButtonTitle
                                                            otherButtonTitles:grantButtonTitle, nil];
        [self.prePhotoPermissionAlertView show];
    } else {
        if (completionHandler) {
            completionHandler((status == ALAuthorizationStatusAuthorized),
                              ClusterDialogResultNoActionTaken,
                              ClusterDialogResultNoActionTaken);
        }
    }
}


- (void) showActualPhotoPermissionAlert
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // Got access! Show login
        [self firePhotoPermissionCompletionHandler];
        *stop = YES;
    } failureBlock:^(NSError *error) {
        // User denied access
        [self firePhotoPermissionCompletionHandler];
    }];
}


- (void) firePhotoPermissionCompletionHandler
{
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (self.photoPermissionCompletionHandler) {
        ClusterDialogResult userDialogResult = ClusterDialogResultGranted;
        ClusterDialogResult systemDialogResult = ClusterDialogResultGranted;
        if (status == ALAuthorizationStatusNotDetermined) {
            userDialogResult = ClusterDialogResultDenied;
            systemDialogResult = ClusterDialogResultNoActionTaken;
        } else if (status == ALAuthorizationStatusAuthorized) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultGranted;
        } else if (status == ALAuthorizationStatusDenied) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultDenied;
        } else if (status == ALAuthorizationStatusRestricted) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultParentallyRestricted;
        }
        self.photoPermissionCompletionHandler((status == ALAuthorizationStatusAuthorized),
                                              userDialogResult,
                                              systemDialogResult);
        self.photoPermissionCompletionHandler = nil;
    }
}


#pragma mark - Contact Permissions Help


- (void) showContactsPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access Contacts?";
    }
    if (denyButtonTitle.length == 0) {
        denyButtonTitle = @"Not Now";
    }
    if (grantButtonTitle.length == 0) {
        grantButtonTitle = @"Give Access";
    }
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        self.contactPermissionCompletionHandler = completionHandler;
        self.preContactPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:denyButtonTitle
                                                              otherButtonTitles:grantButtonTitle, nil];
        [self.preContactPermissionAlertView show];
    } else {
        if (completionHandler) {
            completionHandler((status == kABAuthorizationStatusAuthorized),
                              ClusterDialogResultNoActionTaken,
                              ClusterDialogResultNoActionTaken);
        }
    }
}


- (void) showActualContactPermissionAlert
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireContactPermissionCompletionHandler];
        });
    });
}


- (void) fireContactPermissionCompletionHandler
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (self.contactPermissionCompletionHandler) {
        ClusterDialogResult userDialogResult = ClusterDialogResultGranted;
        ClusterDialogResult systemDialogResult = ClusterDialogResultGranted;
        if (status == kABAuthorizationStatusNotDetermined) {
            userDialogResult = ClusterDialogResultDenied;
            systemDialogResult = ClusterDialogResultNoActionTaken;
        } else if (status == kABAuthorizationStatusAuthorized) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultGranted;
        } else if (status == kABAuthorizationStatusDenied) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultDenied;
        } else if (status == kABAuthorizationStatusRestricted) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultParentallyRestricted;
        }
        self.contactPermissionCompletionHandler((status == kABAuthorizationStatusAuthorized),
                                                userDialogResult,
                                                systemDialogResult);
        self.contactPermissionCompletionHandler = nil;
    }
}


#pragma mark - UIAlertViewDelegate


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.prePhotoPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, jerk.
            [self firePhotoPermissionCompletionHandler];
        } else {
            // User granted access, now show the REAL permissions dialog
            [self showActualPhotoPermissionAlert];
        }

        self.prePhotoPermissionAlertView = nil;
    } else if (alertView == self.preContactPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self fireContactPermissionCompletionHandler];
        } else {
            // User granted access, now try to trigger the real contacts access
            [self showActualContactPermissionAlert];
        }
    }
}

@end
