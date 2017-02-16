//
//  AppDelegate.h
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GCKUIMiniMediaControlsViewController *miniMediaControlsViewController;

//MARK: Mini Controller
- (void)setCastControlBarsEnabled:(BOOL)notificationsEnabled;
- (BOOL)castControlBarsEnabled;
- (void)appearExpandedControlWithNavigationitem: (UINavigationItem *)navigationItem;
- (BOOL)shouldAppearExpandedControlWithCurrentEntryId:(NSString *)currentEntryId;

@end

#define appDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)
