//
//  CLPermissions.m
//  CLPermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import "CLPermissions.h"

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CLPermissions () <UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *prePhotoPermissionAlertView;
@property (copy, nonatomic) CLPermissionCompletionHandler photoPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preContactPermissionAlertView;
@property (copy, nonatomic) CLPermissionCompletionHandler contactPermissionCompletionHandler;

@end

static CLPermissions *__sharedInstance;

@implementation CLPermissions

+ (instancetype) sharedPermissions
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CLPermissions alloc] init];
    });
    return __sharedInstance;
}


#pragma mark - Photo Permissions Help


- (void) requestPhotoPermissionsIfNeededWithRequestTitle:(NSString *)requestTitle
                                                 message:(NSString *)message
                                         denyButtonTitle:(NSString *)denyButtonTitle
                                        grantButtonTitle:(NSString *)grantButtonTitle
                                       completionHandler:(CLPermissionCompletionHandler)completionHandler
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
                              CLDialogResultNoActionTaken,
                              CLDialogResultNoActionTaken);
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
        CLDialogResult userDialogResult = CLDialogResultGranted;
        CLDialogResult systemDialogResult = CLDialogResultGranted;
        if (status == ALAuthorizationStatusNotDetermined) {
            userDialogResult = CLDialogResultDenied;
            systemDialogResult = CLDialogResultNoActionTaken;
        } else if (status == ALAuthorizationStatusAuthorized) {
            userDialogResult = CLDialogResultGranted;
            systemDialogResult = CLDialogResultGranted;
        } else if (status == ALAuthorizationStatusDenied) {
            userDialogResult = CLDialogResultGranted;
            systemDialogResult = CLDialogResultDenied;
        } else if (status == ALAuthorizationStatusRestricted) {
            userDialogResult = CLDialogResultGranted;
            systemDialogResult = CLDialogResultParentallyRestricted;
        }
        self.photoPermissionCompletionHandler((status == ALAuthorizationStatusAuthorized),
                                              userDialogResult,
                                              systemDialogResult);
        self.photoPermissionCompletionHandler = nil;
    }
}


#pragma mark - Contact Permissions Help


- (void) requestContactsPermissionsIfNeededWithRequestTitle:(NSString *)requestTitle
                                                    message:(NSString *)message
                                            denyButtonTitle:(NSString *)denyButtonTitle
                                           grantButtonTitle:(NSString *)grantButtonTitle
                                          completionHandler:(CLPermissionCompletionHandler)completionHandler
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
                              CLDialogResultNoActionTaken,
                              CLDialogResultNoActionTaken);
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
        CLDialogResult userDialogResult = CLDialogResultGranted;
        CLDialogResult systemDialogResult = CLDialogResultGranted;
        if (status == kABAuthorizationStatusNotDetermined) {
            userDialogResult = CLDialogResultDenied;
            systemDialogResult = CLDialogResultNoActionTaken;
        } else if (status == kABAuthorizationStatusAuthorized) {
            userDialogResult = CLDialogResultGranted;
            systemDialogResult = CLDialogResultGranted;
        } else if (status == kABAuthorizationStatusDenied) {
            userDialogResult = CLDialogResultGranted;
            systemDialogResult = CLDialogResultDenied;
        } else if (status == kABAuthorizationStatusRestricted) {
            userDialogResult = CLDialogResultGranted;
            systemDialogResult = CLDialogResultParentallyRestricted;
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
