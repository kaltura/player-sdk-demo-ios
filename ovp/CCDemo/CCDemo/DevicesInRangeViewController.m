//
//  DevicesInRangeViewController.m
//  ChromeCastDemo
//
//  Created by Nissim Pardo on 01/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "DevicesInRangeViewController.h"

@interface DevicesInRangeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *castDevicesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightContraint;

@end

@implementation DevicesInRangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_device) {
        _devices = @[@"Disconnect"];
    }
    _tableViewHeightContraint.constant = (_devices.count + 1) * 49.0;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _devices.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CastDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row == _devices.count) {
        cell.device = nil;
    } else {
        cell.device = _devices[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 if (indexPath.row != _devices.count) {
                                     if (_device) {
                                         [_delegate disconnect];
                                     } else {
                                         [_delegate didSelectDevice:_devices[indexPath.row]];
                                     }
                                 }
                             }];
    
}
@end
