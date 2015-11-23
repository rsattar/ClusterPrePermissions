//
//  ClusterAlertView.h
//  ClusterPrePermissions
//
//  Created by Hossam Ghareeb(hossam.ghareb@gmail.com) on 11/23/15.
//  Copyright © 2015 Cluster Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ClusterAlertViewCompletion)(NSInteger selectedOtherButtonIndex);

@interface ClusterAlertView : NSObject


+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelTitle otherButtonTitles:(NSArray *)otherButtonTitles completion:(ClusterAlertViewCompletion)completion;
@end
