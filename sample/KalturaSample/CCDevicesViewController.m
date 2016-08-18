//
//  CCDevicesViewController.m
//  KalturaSample
//
//  Created by Vitaliy Rusinov on 7/20/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "CCDevicesViewController.h"

static NSString * const kCCDevicesViewControllerIdentifier = @"CCDevicesViewControllerIdentifier";

@interface CCDevicesViewController ()

@property (nonatomic, strong) NSArray *list;

@end

@implementation CCDevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void) shouldUpdateWithListOfDevices:(NSArray *)devices {

    self.list = [devices copy];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_delegate respondsToSelector:@selector(devicesViewControler:didSelectDevice:)]) {
        
        KCastDevice *device = _list[indexPath.row];
        if (device) {
            
            [_delegate devicesViewControler: self didSelectDevice: device];
        }
    }
    
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kCCDevicesViewControllerIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: kCCDevicesViewControllerIdentifier];
    }
    
    KCastDevice *device = _list[indexPath.row];
    if (device) {
        
        cell.textLabel.text = device.routerName;
    }
    
    return cell;
}

@end
