//
//  CCDevicesViewController.h
//  KalturaSample
//
//  Created by Vitaliy Rusinov on 7/20/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KALTURAPlayerSDK/KPViewController.h>
#import <KalturaPlayerSDK/KPLocalAssetsManager.h>

@class CCDevicesViewController;

@protocol CCDevicesViewControllerDelegate  <NSObject>

- (void) devicesViewControler:(CCDevicesViewController *)viewController didSelectDevice: (KCastDevice *)device;

@end

@interface CCDevicesViewController : UITableViewController

@property (nonatomic, weak) id<CCDevicesViewControllerDelegate> delegate;
- (void) shouldUpdateWithListOfDevices:(NSArray *)devices;

@end
