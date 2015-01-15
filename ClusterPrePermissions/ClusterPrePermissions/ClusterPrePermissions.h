//
//  ClusterPrePermissions.h
//  ClusterPrePermissions
//
//  Created by Rizwan Sattar on 4/7/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>

@interface ClusterPrePermissions : NSObject

/**
 * A general descriptor for the possible outcomes of a dialog.
 */
typedef NS_ENUM(NSInteger, ClusterDialogResult) {
    /// User was not given the chance to take action.
    /// This can happen if the permission was
    /// already granted, denied, or restricted.
    ClusterDialogResultNoActionTaken,
    /// User declined access in the user dialog or system dialog.
    ClusterDialogResultDenied,
    /// User granted access in the user dialog or system dialog.
    ClusterDialogResultGranted,
    /// The iOS parental permissions prevented access.
    /// This outcome would only happen on the system dialog.
    ClusterDialogResultParentallyRestricted
};

/**
 * A general descriptor for the possible outcomes of Authorization Status.
 */
typedef NS_ENUM(NSInteger, ClusterAuthorizationStatus) {
    /// Permission status undetermined.
    ClusterAuthorizationStatusUnDetermined,
    /// Permission denied.
    ClusterAuthorizationStatusDenied,
    /// Permission authorized.
    ClusterAuthorizationStatusAuthorized,
    /// The iOS parental permissions prevented access.
    ClusterAuthorizationStatusRestricted
};

/**
 * Authorization methods for the usage of location services.
 */
typedef NS_ENUM(NSInteger, ClusterLocationAuthorizationType) {
    /// the “when-in-use” authorization grants the app to start most
    /// (but not all) location services while it is in the foreground.
    ClusterLocationAuthorizationTypeWhenInUse,
    /// the “always” authorization grants the app to start all
    /// location services
    ClusterLocationAuthorizationTypeAlways,
};

/**
 * Authorization methods for the usage of event services.
 */
typedef NS_ENUM(NSInteger, ClusterEventAuthorizationType) {
    /// Authorization for events only
    ClusterEventAuthorizationTypeEvent,
    /// Authorization for reminders only
    ClusterEventAuthorizationTypeReminder
};

/**
 * Authorization methods for the usage of AV services.
 */
typedef NS_ENUM(NSInteger, ClusterAVAuthorizationType) {
    /// Authorization for Camera only
    ClusterAVAuthorizationTypeCamera,
    /// Authorization for Microphone only
    ClusterAVAuthorizationTypeMicrophone
};

/**
 * General callback for permissions. 
 * @param hasPermission Returns YES if system permission was granted 
 *                      or is already available, NO otherwise.
 * @param userDialogResult Describes whether the user granted/denied access, 
 *                         or if the user didn't have an opportunity to take action. 
 *                         ClusterDialogResultParentallyRestricted is never returned.
 * @param systemDialogResult Describes whether the user granted/denied access, 
 *                           or was parentally restricted, or if the user didn't 
 *                           have an opportunity to take action.
 * @see ClusterDialogResult
 */
typedef void (^ClusterPrePermissionCompletionHandler)(BOOL hasPermission,
                                              ClusterDialogResult userDialogResult,
                                              ClusterDialogResult systemDialogResult);

+ (instancetype) sharedPermissions;

+ (ClusterAuthorizationStatus) cameraPermissionAuthorizationStatus;
+ (ClusterAuthorizationStatus) microphonePermissionAuthorizationStatus;
+ (ClusterAuthorizationStatus) photoPermissionAuthorizationStatus;
+ (ClusterAuthorizationStatus) contactsPermissionAuthorizationStatus;
+ (ClusterAuthorizationStatus) eventPermissionAuthorizationStatus:(ClusterEventAuthorizationType)eventType;
+ (ClusterAuthorizationStatus) locationPermissionAuthorizationStatus;

- (void) showAVPermissionsWithType:(ClusterAVAuthorizationType)mediaType
                             title:(NSString *)requestTitle
                           message:(NSString *)message
                   denyButtonTitle:(NSString *)denyButtonTitle
                  grantButtonTitle:(NSString *)grantButtonTitle
                completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showCameraPermissionsWithTitle:(NSString *)requestTitle
                                message:(NSString *)message
                        denyButtonTitle:(NSString *)denyButtonTitle
                       grantButtonTitle:(NSString *)grantButtonTitle
                      completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showMicrophonePermissionsWithTitle:(NSString *)requestTitle
                                    message:(NSString *)message
                            denyButtonTitle:(NSString *)denyButtonTitle
                           grantButtonTitle:(NSString *)grantButtonTitle
                          completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showPhotoPermissionsWithTitle:(NSString *)requestTitle
                               message:(NSString *)message
                       denyButtonTitle:(NSString *)denyButtonTitle
                      grantButtonTitle:(NSString *)grantButtonTitle
                     completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showContactsPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showEventPermissionsWithType:(ClusterEventAuthorizationType)eventType
                                Title:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showLocationPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

- (void) showLocationPermissionsForAuthorizationType:(ClusterLocationAuthorizationType)authorizationType
                                               title:(NSString *)requestTitle
                                             message:(NSString *)message
                                     denyButtonTitle:(NSString *)denyButtonTitle
                                    grantButtonTitle:(NSString *)grantButtonTitle
                                   completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler;

@end
