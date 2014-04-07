//
//  CLPermissions.h
//  CLPermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLPermissions : NSObject

/**
 * A general descriptor for the possible outcomes of a dialog.
 */
typedef NS_ENUM(NSInteger, CLDialogResult) {
    /// User was not given the chance to take action.
    /// This can happen if the permission was
    /// already granted, denied, or restricted.
    CLDialogResultNoActionTaken,
    /// User declined access in the user dialog or system dialog.
    CLDialogResultDenied,
    /// User granted access in the user dialog or system dialog.
    CLDialogResultGranted,
    /// The iOS parental permissions prevented access.
    /// This outcome would only happen on the system dialog.
    CLDialogResultParentallyRestricted
};

/**
 * General callback for permissions. 
 * @param hasPermission Returns YES if system permission was granted 
 *                      or is already available, NO otherwise.
 * @param userDialogResult Describes whether the user granted/denied access, 
 *                         or if the user didn't have an opportunity to take action. 
 *                         CLDialogResultParentallyRestricted is never returned.
 * @param systemDialogResult Describes whether the user granted/denied access, 
 *                           or was parentally restricted, or if the user didn't 
 *                           have an opportunity to take action.
 * @see CLDialogResult
 */
typedef void (^CLPermissionCompletionHandler)(BOOL hasPermission,
                                              CLDialogResult userDialogResult,
                                              CLDialogResult systemDialogResult);

+ (instancetype) sharedPermissions;

- (void) requestPhotoPermissionsIfNeededWithRequestTitle:(NSString *)requestTitle
                                                 message:(NSString *)message
                                         denyButtonTitle:(NSString *)denyButtonTitle
                                        grantButtonTitle:(NSString *)grantButtonTitle
                                       completionHandler:(CLPermissionCompletionHandler)completionHandler;

- (void) requestContactsPermissionsIfNeededWithRequestTitle:(NSString *)requestTitle
                                                    message:(NSString *)message
                                            denyButtonTitle:(NSString *)denyButtonTitle
                                           grantButtonTitle:(NSString *)grantButtonTitle
                                          completionHandler:(CLPermissionCompletionHandler)completionHandler;
@end
