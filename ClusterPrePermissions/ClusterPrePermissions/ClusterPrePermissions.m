//
//  ClusterPrePermissions.m
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

typedef NS_ENUM(NSInteger, ClusterTitleType) {
    ClusterTitleTypeRequest,
    ClusterTitleTypeDeny
};


#import "ClusterPrePermissions.h"

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <EventKit/EventKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

@interface ClusterPrePermissions () <UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIAlertView *preAVPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler avPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *prePhotoPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler photoPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preContactPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler contactPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preEventPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler eventPermissionCompletionHandler;

@property (strong, nonatomic) UIAlertView *preLocationPermissionAlertView;
@property (copy, nonatomic) ClusterPrePermissionCompletionHandler locationPermissionCompletionHandler;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (assign, nonatomic) ClusterLocationAuthorizationType locationAuthorizationType;

+ (ClusterAuthorizationStatus) AVPermissionAuthorizationStatusForMediaType:(NSString*)mediaType;
- (void) showActualAVPermissionAlertWithType:(ClusterAVAuthorizationType)mediaType;
- (void) showActualPhotoPermissionAlert;
- (void) showActualContactPermissionAlert;
- (void) showActualEventPermissionAlert:(ClusterEventAuthorizationType)eventType;
- (void) showActualLocationPermissionAlert;

- (void) fireAVPermissionCompletionHandlerWithType:(ClusterAVAuthorizationType)mediaType;
- (NSString*)AVEquivalentMediaType:(ClusterAVAuthorizationType)mediaType;
- (void) firePhotoPermissionCompletionHandler;
- (void) fireContactPermissionCompletionHandler;
- (void) fireEventPermissionCompletionHandler:(ClusterEventAuthorizationType)eventType;
- (void) fireLocationPermissionCompletionHandler;
- (NSUInteger)EKEquivalentEventType:(ClusterEventAuthorizationType)eventType;
- (BOOL)locationAuthorizationStatusPermitsAccess:(CLAuthorizationStatus)authorizationStatus;
- (NSString *)titleFor:(ClusterTitleType)titleType fromTitle:(NSString *)title;

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

+ (ClusterAuthorizationStatus) AVPermissionAuthorizationStatusForMediaType:(NSString*)mediaType
{
    int status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return ClusterAuthorizationStatusAuthorized;
            
        case AVAuthorizationStatusDenied:
            return ClusterAuthorizationStatusDenied;
            
        case AVAuthorizationStatusRestricted:
            return ClusterAuthorizationStatusRestricted;
            
        default:
            return ClusterAuthorizationStatusUnDetermined;
    }
}

+ (ClusterAuthorizationStatus) cameraPermissionAuthorizationStatus
{
    return [ClusterPrePermissions AVPermissionAuthorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (ClusterAuthorizationStatus) microphonePermissionAuthorizationStatus
{
    return [ClusterPrePermissions AVPermissionAuthorizationStatusForMediaType:AVMediaTypeAudio];
}

+ (ClusterAuthorizationStatus) photoPermissionAuthorizationStatus
{
    int status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusAuthorized:
            return ClusterAuthorizationStatusAuthorized;
            
        case ALAuthorizationStatusDenied:
            return ClusterAuthorizationStatusDenied;
            
        case ALAuthorizationStatusRestricted:
            return ClusterAuthorizationStatusRestricted;
            
        default:
            return ClusterAuthorizationStatusUnDetermined;
    }
}

+ (ClusterAuthorizationStatus) contactsPermissionAuthorizationStatus
{
    int status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusAuthorized:
            return ClusterAuthorizationStatusAuthorized;
            
        case kABAuthorizationStatusDenied:
            return ClusterAuthorizationStatusDenied;
            
        case kABAuthorizationStatusRestricted:
            return ClusterAuthorizationStatusRestricted;
            
        default:
            return ClusterAuthorizationStatusUnDetermined;
    }
}

+ (ClusterAuthorizationStatus) eventPermissionAuthorizationStatus:(ClusterEventAuthorizationType)eventType
{
    int status = [EKEventStore authorizationStatusForEntityType:
                  [[ClusterPrePermissions sharedPermissions] EKEquivalentEventType:eventType]];
    switch (status) {
        case EKAuthorizationStatusAuthorized:
            return ClusterAuthorizationStatusAuthorized;
            
        case EKAuthorizationStatusDenied:
            return ClusterAuthorizationStatusDenied;
            
        case EKAuthorizationStatusRestricted:
            return ClusterAuthorizationStatusRestricted;
            
        default:
            return ClusterAuthorizationStatusUnDetermined;
    }
}

+ (ClusterAuthorizationStatus) locationPermissionAuthorizationStatus
{
    int status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return ClusterAuthorizationStatusAuthorized;
            
        case kCLAuthorizationStatusDenied:
            return ClusterAuthorizationStatusDenied;
            
        case kCLAuthorizationStatusRestricted:
            return ClusterAuthorizationStatusRestricted;
            
        default:
            return ClusterAuthorizationStatusUnDetermined;
    }
}

#pragma mark - AV Permissions Help

- (void) showAVPermissionsWithType:(ClusterAVAuthorizationType)mediaType
                             title:(NSString *)requestTitle
                           message:(NSString *)message
                   denyButtonTitle:(NSString *)denyButtonTitle
                  grantButtonTitle:(NSString *)grantButtonTitle
                 completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        switch (mediaType) {
            case ClusterAVAuthorizationTypeCamera:
                requestTitle = @"Access Camera?";
                break;
            
            default:
                requestTitle = @"Access Microphone?";
                break;
        }
    }
    denyButtonTitle  = [self titleFor:ClusterTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:ClusterTitleTypeRequest fromTitle:grantButtonTitle];
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        self.avPermissionCompletionHandler = completionHandler;
        self.preAVPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                   message:message
                                                                  delegate:self
                                                         cancelButtonTitle:denyButtonTitle
                                                         otherButtonTitles:grantButtonTitle, nil];
        self.preAVPermissionAlertView.tag = mediaType;
        [self.preAVPermissionAlertView show];
    } else {
        if (completionHandler) {
            completionHandler((status == AVAuthorizationStatusAuthorized),
                              ClusterDialogResultNoActionTaken,
                              ClusterDialogResultNoActionTaken);
        }
    }
}


- (void) showCameraPermissionsWithTitle:(NSString *)requestTitle
                                message:(NSString *)message
                        denyButtonTitle:(NSString *)denyButtonTitle
                       grantButtonTitle:(NSString *)grantButtonTitle
                      completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    [self showAVPermissionsWithType:ClusterAVAuthorizationTypeCamera title:requestTitle message:message denyButtonTitle:denyButtonTitle grantButtonTitle:grantButtonTitle completionHandler:completionHandler];
}


- (void) showMicrophonePermissionsWithTitle:(NSString *)requestTitle
                                    message:(NSString *)message
                            denyButtonTitle:(NSString *)denyButtonTitle
                           grantButtonTitle:(NSString *)grantButtonTitle
                          completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    [self showAVPermissionsWithType:ClusterAVAuthorizationTypeMicrophone title:requestTitle message:message denyButtonTitle:denyButtonTitle grantButtonTitle:grantButtonTitle completionHandler:completionHandler];
}


- (void) showActualAVPermissionAlertWithType:(ClusterAVAuthorizationType)mediaType
{
    [AVCaptureDevice requestAccessForMediaType:[self AVEquivalentMediaType:mediaType]
                             completionHandler:^(BOOL granted) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self fireAVPermissionCompletionHandlerWithType:mediaType];
                                    });
                             }];
}


- (void) fireAVPermissionCompletionHandlerWithType:(ClusterAVAuthorizationType)mediaType
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:[self AVEquivalentMediaType:mediaType]];
    if (self.avPermissionCompletionHandler) {
        ClusterDialogResult userDialogResult = ClusterDialogResultGranted;
        ClusterDialogResult systemDialogResult = ClusterDialogResultGranted;
        if (status == AVAuthorizationStatusNotDetermined) {
            userDialogResult = ClusterDialogResultDenied;
            systemDialogResult = ClusterDialogResultNoActionTaken;
        } else if (status == AVAuthorizationStatusAuthorized) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultGranted;
        } else if (status == AVAuthorizationStatusDenied) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultDenied;
        } else if (status == AVAuthorizationStatusRestricted) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultParentallyRestricted;
        }
        self.avPermissionCompletionHandler((status == AVAuthorizationStatusAuthorized),
                                              userDialogResult,
                                              systemDialogResult);
        self.avPermissionCompletionHandler = nil;
    }
}


- (NSString*)AVEquivalentMediaType:(ClusterAVAuthorizationType)mediaType
{
    if (mediaType == ClusterAVAuthorizationTypeCamera) {
        return AVMediaTypeVideo;
    }
    else {
        return AVMediaTypeAudio;
    }
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
    denyButtonTitle  = [self titleFor:ClusterTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:ClusterTitleTypeRequest fromTitle:grantButtonTitle];
    
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
    denyButtonTitle  = [self titleFor:ClusterTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:ClusterTitleTypeRequest fromTitle:grantButtonTitle];
    
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

#pragma mark - Event Permissions Help


- (void) showEventPermissionsWithType:(ClusterEventAuthorizationType)eventType
                                Title:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        switch (eventType) {
            case ClusterEventAuthorizationTypeEvent:
                requestTitle = @"Access Calendar?";
                break;
                
            default:
                requestTitle = @"Access Reminders?";
                break;
        }
    }
    denyButtonTitle  = [self titleFor:ClusterTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:ClusterTitleTypeRequest fromTitle:grantButtonTitle];
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:[self EKEquivalentEventType:eventType]];
    if (status == EKAuthorizationStatusNotDetermined) {
        self.eventPermissionCompletionHandler = completionHandler;
        self.preEventPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:denyButtonTitle
                                                              otherButtonTitles:grantButtonTitle, nil];
        self.preEventPermissionAlertView.tag = eventType;
        [self.preEventPermissionAlertView show];
    } else {
        if (completionHandler) {
            completionHandler((status == EKAuthorizationStatusAuthorized),
                              ClusterDialogResultNoActionTaken,
                              ClusterDialogResultNoActionTaken);
        }
    }
}


- (void) showActualEventPermissionAlert:(ClusterEventAuthorizationType)eventType
{
    EKEventStore *aStore = [[EKEventStore alloc] init];
    [aStore requestAccessToEntityType:[self EKEquivalentEventType:eventType] completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireEventPermissionCompletionHandler:eventType];
        });
    }];
}


- (void) fireEventPermissionCompletionHandler:(ClusterEventAuthorizationType)eventType
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:[self EKEquivalentEventType:eventType]];
    if (self.eventPermissionCompletionHandler) {
        ClusterDialogResult userDialogResult = ClusterDialogResultGranted;
        ClusterDialogResult systemDialogResult = ClusterDialogResultGranted;
        if (status == EKAuthorizationStatusNotDetermined) {
            userDialogResult = ClusterDialogResultDenied;
            systemDialogResult = ClusterDialogResultNoActionTaken;
        } else if (status == EKAuthorizationStatusAuthorized) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultGranted;
        } else if (status == EKAuthorizationStatusDenied) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultDenied;
        } else if (status == EKAuthorizationStatusRestricted) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultParentallyRestricted;
        }
        self.eventPermissionCompletionHandler((status == EKAuthorizationStatusAuthorized),
                                                userDialogResult,
                                                systemDialogResult);
        self.eventPermissionCompletionHandler = nil;
    }
}

- (NSUInteger)EKEquivalentEventType:(ClusterEventAuthorizationType)eventType {
    if (eventType == ClusterEventAuthorizationTypeEvent) {
        return EKEntityTypeEvent;
    }
    else {
        return EKEntityTypeReminder;
    }
}

#pragma mark - Location Permission Help



- (void) showLocationPermissionsWithTitle:(NSString *)requestTitle
                                  message:(NSString *)message
                          denyButtonTitle:(NSString *)denyButtonTitle
                         grantButtonTitle:(NSString *)grantButtonTitle
                        completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    [self showLocationPermissionsForAuthorizationType:ClusterLocationAuthorizationTypeAlways
                                                title:requestTitle
                                              message:message
                                      denyButtonTitle:denyButtonTitle
                                     grantButtonTitle:grantButtonTitle
                                    completionHandler:completionHandler];
}

- (void) showLocationPermissionsForAuthorizationType:(ClusterLocationAuthorizationType)authorizationType
                                               title:(NSString *)requestTitle
                                             message:(NSString *)message
                                     denyButtonTitle:(NSString *)denyButtonTitle
                                    grantButtonTitle:(NSString *)grantButtonTitle
                                   completionHandler:(ClusterPrePermissionCompletionHandler)completionHandler
{
    if (requestTitle.length == 0) {
        requestTitle = @"Access Location?";
    }
    denyButtonTitle  = [self titleFor:ClusterTitleTypeDeny fromTitle:denyButtonTitle];
    grantButtonTitle = [self titleFor:ClusterTitleTypeRequest fromTitle:grantButtonTitle];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        self.locationPermissionCompletionHandler = completionHandler;
        self.locationAuthorizationType = authorizationType;
        self.preLocationPermissionAlertView = [[UIAlertView alloc] initWithTitle:requestTitle
                                                                         message:message
                                                                        delegate:self
                                                               cancelButtonTitle:denyButtonTitle
                                                               otherButtonTitles:grantButtonTitle, nil];
        [self.preLocationPermissionAlertView show];
    } else {
        if (completionHandler) {
            completionHandler(([self locationAuthorizationStatusPermitsAccess:status]),
                              ClusterDialogResultNoActionTaken,
                              ClusterDialogResultNoActionTaken);
        }
    }
}


- (void) showActualLocationPermissionAlert
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (self.locationAuthorizationType == ClusterLocationAuthorizationTypeAlways &&
        [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    } else
        if (self.locationAuthorizationType == ClusterLocationAuthorizationTypeWhenInUse &&
            [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    
    [self.locationManager startUpdatingLocation];
}


- (void) fireLocationPermissionCompletionHandler
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (self.locationPermissionCompletionHandler) {
        ClusterDialogResult userDialogResult = ClusterDialogResultGranted;
        ClusterDialogResult systemDialogResult = ClusterDialogResultGranted;
        if (status == kCLAuthorizationStatusNotDetermined) {
            userDialogResult = ClusterDialogResultDenied;
            systemDialogResult = ClusterDialogResultNoActionTaken;
        } else if ([self locationAuthorizationStatusPermitsAccess:status]) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultGranted;
        } else if (status == kCLAuthorizationStatusDenied) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultDenied;
        } else if (status == kCLAuthorizationStatusRestricted) {
            userDialogResult = ClusterDialogResultGranted;
            systemDialogResult = ClusterDialogResultParentallyRestricted;
        }
        self.locationPermissionCompletionHandler(([self locationAuthorizationStatusPermitsAccess:status]),
                                                 userDialogResult,
                                                 systemDialogResult);
        self.locationPermissionCompletionHandler = nil;
    }
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation], self.locationManager = nil;
    }
}

- (BOOL)locationAuthorizationStatusPermitsAccess:(CLAuthorizationStatus)authorizationStatus
{
    return authorizationStatus == kCLAuthorizationStatusAuthorized ||
    authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
    authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse;
}

#pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self fireLocationPermissionCompletionHandler];
    }
}


#pragma mark - UIAlertViewDelegate


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.preAVPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, jerk.
            [self fireAVPermissionCompletionHandlerWithType:alertView.tag];
        } else {
            // User granted access, now show the REAL permissions dialog
            [self showActualAVPermissionAlertWithType:alertView.tag];
        }
        
        self.preAVPermissionAlertView = nil;
    } else if (alertView == self.prePhotoPermissionAlertView) {
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
    } else if (alertView == self.preEventPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self fireEventPermissionCompletionHandler:alertView.tag];
        } else {
            // User granted access, now try to trigger the real contacts access
            [self showActualEventPermissionAlert:alertView.tag];
        }
    } else if (alertView == self.preLocationPermissionAlertView) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            // User said NO, that jerk.
            [self fireLocationPermissionCompletionHandler];
        } else {
            // User granted access, now try to trigger the real location access
            [self showActualLocationPermissionAlert];
        }
    }
}

#pragma mark - Titles

- (NSString *)titleFor:(ClusterTitleType)titleType fromTitle:(NSString *)title
{
    switch (titleType) {
        case ClusterTitleTypeDeny:
            title = (title.length == 0) ? @"Not Now" : title;
            break;
        case ClusterTitleTypeRequest:
            title = (title.length == 0) ? @"Give Access" : title;
            break;
        default:
            title = @"";
            break;
    }
    return title;
}

@end
