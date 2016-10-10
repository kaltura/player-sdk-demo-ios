//
//  AppDelegate.m
//  CCDemo
//
//  Created by Nissim Pardo on 02/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleCast/GoogleCast.h>

@interface AppDelegate () <GCKLoggerDelegate>

@end

@implementation AppDelegate

//F16506C7 2.48.4
// 276999A7 2.48.3
static NSString *const kReceiverAppID = @"276999A7";
static const BOOL kDebugLoggingEnabled = YES;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    GCKCastOptions *options =
    [[GCKCastOptions alloc] initWithReceiverApplicationID:kReceiverAppID];
    [GCKCastContext setSharedInstanceWithOptions:options];
    
    [GCKLogger sharedInstance].delegate = self;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - GCKLoggerDelegate

- (void)logMessage:(NSString *)message fromFunction:(NSString *)function {
    if (kDebugLoggingEnabled) {
        NSLog(@"%@  %@", function, message);
    }
}

@end
