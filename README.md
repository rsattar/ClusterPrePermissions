# ClusterPrePermissions

Cluster's reusable pre-permissions utility that lets developers ask the users on their own dialog for photos or contacts access, before making the system-based request. This is based on [Cluster's post *The Right Way to Ask Users for iOS Permissions*](https://medium.com/p/96fa4eb54f2c).

#####Supported permissions: 
- Photo Library
- Camera
- Microphone
- Contacts List
- Events
- Location

# Why use Pre-Permissions?

On iOS, when your code tries to access the Camera Roll or the Address Book, the system automatically shows an alert to the user. 

If the user says "Don't Allow" to this alert, **you have burned your one-and-only chance to get that access**. The user will have to jump through a 5-step process outside of your app to re-enable access, which they will rarely, if ever, do. 

Often the user wasn't event expecting the access alert, and by habit will tap "Don't Allow". This is a lose-lose scenario for both you and your user.

At [Cluster](http://cluster.co), we’ve had a lot of success asking for permissions using our own UI before popping the iOS dialogs.

**For photos alone, 46% of people who denied access in a pre-permissions dialog ended up granting access when asked at a better time later.**

# How Pre-Permissions Works


This utility simply wraps your code with a "pre-permission" alert, if needed. When you need to ask for photo access, for example, this utility essentially just asks them twice.

![image](http://f.cl.ly/items/2I1V1R3b3q3A3H3y3u18/new-1.jpg)

Even though it seems annoying to ask twice, at Cluster we almost completely eliminated the possibility of a user tapping “Don’t Allow”, leaving the door open for us to win them back in the future. And for what it’s worth, in [live user tests](https://medium.com/ux-ui-design/9b7e9edd2de8), not a single test subject hesitated (or expressed confusion) when the second dialog appeared.

# Adding ClusterPrePermissions to your project

## Cocoapods

[CocoaPods](http://cocoapods.org/) is the recommended way to add ClusterPrePermissions to your project.

1. Add a pod entry for ClusterPrePermissions to your Podfile `pod 'ClusterPrePermissions', '~> 0.1'`
2. Install the pod(s) by running `pod install`
3. Include ClusterPrePermissions wherever you need it with `#import <ClusterPrePermissions/ClusterPrePermissions.h>`

## Source Files

Add `ClusterPrePermissions.h` and `ClusterPrePermissions.m` into your project.

1. Download the latest code, using `git clone`.
2. Open your project in Xcode, then drag and drop `ClusterPrePermissions.h` and `ClusterPrePermissions.m`onto your project (Make sure to select Copy items when asked if you extracted the code archive outside of your project.)
3. In your classes where you need ClusterPrePermissions, add it with `#import "ClusterPrePermissions.h"`


# Usage

CLPermissions checks the authorization status of photos and contacts, and, given a block callback, will return with the result. If authorization status is "not determined", the utility will show a configurable `UIAlertView` that asks for "pre-permission" before making the actual system request.

If the authorization status already unchangeable, your block will just be called back. You can check the `userDialogResult` and `systemDialogResult` to see what happened. If both are `ClusterDialogResultNoActionTaken`, then it means the access was already denied or granted by the system.

```objc
ClusterPrePermissions *permissions = [ClusterPrePermissions sharedPermissions];
[permissions showPhotoPermissionsWithTitle:@"Access your photos?"
                                   message:@"Your message here"
                           denyButtonTitle:@"Not Now"
                          grantButtonTitle:@"Give Access"
                         completionHandler:^(BOOL hasPermission,
                                             ClusterDialogResult userDialogResult,
                                             ClusterDialogResult systemDialogResult) {
                             if (hasPermission) {
                                 // Continue with your code here
                             } else {
                             	  // Handle access not being available
                             }
                         }];
```
