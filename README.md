CLPermissions
=============

Cluster's reusable pre-permissions utility that lets developers ask the users on their own dialog for photos or contacts access, before making the system-based request. This is based on the Medium post by Cluster describing the different ways to ask for iOS permissions (https://medium.com/p/96fa4eb54f2c).

Usage
=====

Add `CLPermissions.h` and `CLPermissions.m` into your project. That's it. The rest of the files are just for demonstrating the utility.

CLPermissions checks the authorization status of photos and contacts, and, given a block callback, will return with the result. If authorization status is "not determined", the utility will show a configurable `UIAlertView` that asks for "pre-permission" before making the actual system request.

    [[CLPermissions sharedPermissions] requestPhotoPermissionsIfNeededWithRequestTitle:nil
                                                                               message:@"We'll never upload without your permission"
                                                                       denyButtonTitle:nil
                                                                      grantButtonTitle:nil
                                                                     completionHandler:^(BOOL hasPermission,
                                                                                         CLDialogResult userDialogResult,
                                                                                         CLDialogResult systemDialogResult) {
                                                                         // Update your UI
                                                                     }];
