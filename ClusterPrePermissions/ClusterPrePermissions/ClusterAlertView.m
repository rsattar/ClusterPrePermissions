//
//  ClusterAlertView.m
//  ClusterPrePermissions
//
//  Created by Hossam Ghareeb on 11/23/15.
//  Copyright © 2015 Cluster Labs, Inc. All rights reserved.
//

#import "ClusterAlertView.h"

typedef void (^AlertControllerHandler)(UIAlertAction *action);

@interface ClusterAlertView () <UIAlertViewDelegate>

@property (nonatomic, copy) ClusterAlertViewCompletion completionHandler;
@end
@implementation ClusterAlertView


+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(ClusterAlertViewCompletion)completion
{

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    //at least iOS 8 code here
    
    __block UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    AlertControllerHandler alertControllerHandler = [^(UIAlertAction *action){
        if (completion) {
            completion([alertController.actions indexOfObject:action]);
        }
        alertController = nil;
    } copy];
    
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:alertControllerHandler]];
    for (NSString *title in otherButtonTitles) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:alertControllerHandler];
        [alertController addAction:action];
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *viewController = keyWindow.rootViewController;
    while (viewController.presentedViewController) {
        viewController = viewController.presentedViewController;
    }
    
    [viewController presentViewController:alertController animated:YES completion:nil];
    
#endif
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
    // less than iOS 8 goes here
    
    __block ClusterAlertView *clusterAlertView = [[self alloc] init];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:clusterAlertView cancelButtonTitle:cancelTitle otherButtonTitles: nil];
    for (NSString *title in otherButtonTitles) {
        [alertView addButtonWithTitle:title];
    }
    
    clusterAlertView.completionHandler = ^(NSInteger index){
      
        if (completion) {
            completion(index);
        }
        clusterAlertView = nil;
    };
    
    [alertView show];
    
#endif
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (self.completionHandler) {
        self.completionHandler(buttonIndex);
    }
}
@end
