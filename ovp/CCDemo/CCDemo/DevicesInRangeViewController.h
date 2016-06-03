//
//  DevicesInRangeViewController.h
//  ChromeCastDemo
//
//  Created by Nissim Pardo on 01/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CastDeviceTableViewCell.h"

@protocol DevicesInRangeViewControllerDelegate <NSObject>

- (void)didSelectDevice:(KCastDevice *)device;
- (void)disconnect;

@end

@interface DevicesInRangeViewController : UIViewController
@property (nonatomic, copy) NSArray<KCastDevice *> *devices;
@property (nonatomic, strong) KCastDevice *device;
@property (nonatomic, weak) id<DevicesInRangeViewControllerDelegate> delegate;
@end
