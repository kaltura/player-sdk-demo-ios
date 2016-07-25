//
//  CCViewController.m
//  KalturaSample
//
//  Created by Vitaliy Rusinov on 7/20/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "CCViewController.h"
#import "KalturaPlayerViewController.h"
#import "CCDevicesViewController.h"

static NSString * const kCCViewControllerUIConfId = @"35750171";
static NSString * const kCCViewControllerPartnerId = @"2164401";
static NSString * const kCCViewControllerEntryId = @"1_jqt5xrs1";
static NSString * const kCCViewControllerCCApplicationId = @"C43947A1";

@interface CCViewController () <KCastProviderDelegate, CCDevicesViewControllerDelegate>

@property (nonatomic, strong) KalturaPlayerViewController *kalturaPlayerViewController;
@property (nonatomic, strong) KCastProvider *castProvider;

@property (nonatomic, weak) IBOutlet UIButton *openDevicesButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectCCButton;

@end

@implementation CCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_kalturaPlayerViewController == nil) {
        
        self.kalturaPlayerViewController = [KalturaPlayerViewController kalturaPlayer];
        
        [self addChildViewController: _kalturaPlayerViewController];
        [self.view addSubview: _kalturaPlayerViewController.view];
        
        _kalturaPlayerViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        
        [_kalturaPlayerViewController reloadConfigureWithUiConfId: kCCViewControllerUIConfId
                                                        partnerId: kCCViewControllerPartnerId
                                                          entryId: kCCViewControllerEntryId
                                                         delegate: nil
                                                 prepareConfBlock:^(KPPlayerConfig *config) {
                                                     
                                                     [config addConfigKey: @"chromecast.plugin" withValue: @"true"];
                                                     [config addConfigKey: @"chromecast.useKalturaPlayer" withValue: @"true"];
                                                 }];
    }
    
    if (_castProvider == nil) {
        
        self.castProvider = [[KCastProvider alloc] init];
        _castProvider.delegate = self;
        
        [self.view bringSubviewToFront: _openDevicesButton];
        [self.view bringSubviewToFront: _disconnectCCButton];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self playerModerator];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.kalturaPlayerViewController pause];
//    [self removePlayerFromSuperView];
}

- (void)playerModerator {
    
    [_castProvider startScan: kCCViewControllerCCApplicationId];
    
    _openDevicesButton.hidden = NO;
    _disconnectCCButton.hidden = YES;
   }

- (void)removePlayerFromSuperView {
    
    [self.kalturaPlayerViewController removePlayer];
    
    [self.kalturaPlayerViewController.view removeFromSuperview];
    [self.kalturaPlayerViewController removeFromParentViewController];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destination = segue.destinationViewController;
    if ([destination isKindOfClass: [CCDevicesViewController class]]) {
        
        CCDevicesViewController *devicesViewController = (CCDevicesViewController *)destination;
        devicesViewController.delegate = self;
        [devicesViewController shouldUpdateWithListOfDevices: [_castProvider devices]];
    }
}

- (IBAction)didClickDisconnect:(id)sender {
    
//    [_castProvider disconnectFromDevice];
    [_castProvider disconnectFromDeviceWithLeave];
    _disconnectCCButton.hidden = YES;
    _openDevicesButton.hidden = NO;
}

#pragma CCDevicesViewControllerDelegate

- (void) devicesViewControler:(CCDevicesViewController *)viewController didSelectDevice: (KCastDevice *)device {
    
    [self.castProvider connectToDevice: device];
}

#pragma mark - KCastProviderDelegate

- (void)castProvider:(KCastProvider *)provider devicesInRange:(BOOL)foundDevices {
    
    NSLog(@"devicesInRange");
    _openDevicesButton.enabled = _castProvider.devices.count;
}

- (void)castProvider:(KCastProvider *)provider didDeviceComeOnline:(KCastDevice *)device {
    
    NSLog(@"didDeviceComeOnline");
}

- (void)castProvider:(KCastProvider *)provider didDeviceGoOffline:(KCastDevice *)device {
    
     NSLog(@"didDeviceGoOffline");
}

- (void)didConnectToDevice:(KCastProvider *)provider {
    
     NSLog(@"didConnectToDevice");
    [_kalturaPlayerViewController initializeCustprovider: _castProvider];
    _openDevicesButton.hidden = YES;
    _disconnectCCButton.hidden = NO;
}

- (void)didDisconnectFromDevice:(KCastProvider *)provider {
    
    NSLog(@"didDisconnectFromDevice");
    _disconnectCCButton.hidden = YES;
    _openDevicesButton.hidden = NO;
}

- (void)castProvider:(KCastProvider *)provider didFailToConnectToDevice:(NSError *)error {
    
    NSLog(@"didFailToConnectToDevice");
}

- (void)castProvider:(KCastProvider *)provider didFailToDisconnectFromDevice:(NSError *)error {
   
    NSLog(@"didFailToDisconnectFromDevice");
}

- (void)castProvider:(KCastProvider *)provider mediaRemoteControlReady:(id<KCastMediaRemoteControl>)mediaRemoteControl {
   
    NSLog(@"mediaRemoteControlReady");
}

@end
