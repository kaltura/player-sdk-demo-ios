//
//  CastDeviceTableViewCell.h
//  ChromeCastDemo
//
//  Created by Nissim Pardo on 01/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KALTURAPlayerSDK/KPViewController.h>

@interface CastDeviceTableViewCell : UITableViewCell
@property (nonatomic, strong) KCastDevice *device;
@end
