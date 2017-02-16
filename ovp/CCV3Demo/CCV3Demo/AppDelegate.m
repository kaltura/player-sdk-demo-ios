//
//  AppDelegate.m
//  CCV3Demo
//
//  Created by Vitaliy Rusinov on 10/11/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "AppDelegate.h"
#import <KalturaPlayerSDK/GoogleCastProvider.h>

@interface AppDelegate ()<GCKLoggerDelegate>
@end

@implementation AppDelegate

static NSString *const kKeyEntryId = @"entryid";
static NSString *const kReceiverAppID = @"276999A7";
static const BOOL kDebugLoggingEnabled = YES;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //The Cast framework has a global singleton object, the CastContext, which coordinates all of the framework's activities. This object must be initialized early in the application's lifecycle, typically in the -[application:didFinishLaunchingWithOptions:] method of the app delegate, so that automatic session resumption on sender app restart can trigger properly.
    GCKCastOptions *options = [[GCKCastOptions alloc] initWithReceiverApplicationID: kReceiverAppID];
    
    //A GCKCastOptions object must be supplied when initializing the CastContext. This class contains options that affect the behavior of the framework. The most important of these is the receiver application ID, which is used to filter discovery results and to launch the receiver app when a Cast session is started.
    [GCKCastContext setSharedInstanceWithOptions: options];
    
    //The -[application:didFinishLaunchingWithOptions:] method is also a good place to set up a logging delegate to receive the logging messages from the framework. These can be useful for debugging and troubleshooting.
    [GCKLogger sharedInstance].delegate = self;
    
    //Configure a GoogleCastProvider shared instance, typically in your application’s application:didFinishLaunchingWithOptions: method, in AppDelegate class:
    [GoogleCastProvider sharedInstance];
    
    //The first thing you have to do is enable the default expanded controller in the cast context. Modify AppDelegate.m to enable the default expanded controller
    [GCKCastContext sharedInstance].useDefaultExpandedMediaControls = YES;
    
    //Add Mini Controllers
    [self p_miniControllerInitializer];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Mini Controllers

- (void)p_miniControllerInitializer {
    
    UIStoryboard *appStoryboard =
    [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navigationController = [appStoryboard instantiateViewControllerWithIdentifier:@"MainNavigation"];
    GCKUICastContainerViewController *castContainerVC = [[GCKCastContext sharedInstance] createCastContainerControllerForViewController:navigationController];
    castContainerVC.miniMediaControlsItemEnabled = YES;
    self.miniMediaControlsViewController = castContainerVC.miniMediaControlsViewController;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = castContainerVC;
    [self.window makeKeyAndVisible];
}

- (void)setCastControlBarsEnabled:(BOOL)notificationsEnabled {
    GCKUICastContainerViewController *castContainerVC = (GCKUICastContainerViewController *)self.window.rootViewController;
    castContainerVC.miniMediaControlsItemEnabled = notificationsEnabled;
}

- (BOOL)castControlBarsEnabled {
    GCKUICastContainerViewController *castContainerVC = (GCKUICastContainerViewController *)self.window.rootViewController;
    return castContainerVC.miniMediaControlsItemEnabled;
}


//Add the following code to load the expanded controller when the user starts to cast a video:
- (void)appearExpandedControlWithNavigationitem: (UINavigationItem *)navigationItem {
    
    navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    [[GCKCastContext sharedInstance] presentDefaultExpandedMediaControls];
}

- (BOOL)shouldAppearExpandedControlWithCurrentEntryId:(NSString *)currentEntryId {
    
    GCKRemoteMediaClient *remoteMediaClient = [[[[GCKCastContext sharedInstance] sessionManager] currentSession] remoteMediaClient];
    NSString *entryIdForCurrentCastMedia = [[[[remoteMediaClient mediaStatus] mediaInformation] metadata] objectForKey: kKeyEntryId];
    BOOL showExpandedMediaControl = entryIdForCurrentCastMedia.length > 0 && [currentEntryId isEqualToString: entryIdForCurrentCastMedia];
    return showExpandedMediaControl;
}

#pragma mark - GCKLoggerDelegate

- (void)logMessage:(NSString *)message fromFunction:(NSString *)function {
    if (kDebugLoggingEnabled) {
        NSLog(@"%@  %@", function, message);
    }
}

@end
