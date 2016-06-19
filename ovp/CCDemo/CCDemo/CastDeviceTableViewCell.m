//
//  CastDeviceTableViewCell.m
//  ChromeCastDemo
//
//  Created by Nissim Pardo on 01/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "CastDeviceTableViewCell.h"

@interface CastDeviceTableViewCell ()
@property (nonatomic, weak) IBOutlet UIImageView *icon;
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
@end

@implementation CastDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDevice:(KCastDevice *)device {
    if ([device isKindOfClass:[NSString class]]) {
        _deviceNameLabel.text = (NSString *)device;
        return;
    }
    if (device) {
        _deviceNameLabel.text = device.routerName;
    } else {
        _deviceNameLabel.text = @"Cancel";
        _icon.hidden = YES;
    }
}
@end
