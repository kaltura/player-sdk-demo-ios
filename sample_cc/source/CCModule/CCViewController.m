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

static NSString * const kCCViewControllerUIConfId = @"35815611";
static NSString * const kCCViewControllerPartnerId = @"2164401";
static NSString * const kCCViewControllerCCApplicationId = @"C43947A1";

@interface CCViewController () <KCastProviderDelegate, CCDevicesViewControllerDelegate>

@property (nonatomic, strong) KalturaPlayerViewController *kalturaPlayerViewController;
@property (nonatomic, strong) KCastProvider *castProvider;

@property (weak, nonatomic) IBOutlet UIButton *castButton;

@property (nonatomic, strong) NSMutableDictionary *devices;

@property (nonatomic, strong) NSString *currentEntryId;

@end

@implementation CCViewController

- (void)shouldUpdateWithEntryId:(NSString *)entryId {
    
    self.currentEntryId = entryId;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if (_kalturaPlayerViewController == nil) {
        
        self.kalturaPlayerViewController = [KalturaPlayerViewController kalturaPlayer];
        
        [self addChildViewController: _kalturaPlayerViewController];
        [self.view addSubview: _kalturaPlayerViewController.view];
        
        _kalturaPlayerViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        
        [_kalturaPlayerViewController reloadConfigureWithUiConfId: kCCViewControllerUIConfId
                                                        partnerId: kCCViewControllerPartnerId
                                                          entryId: _currentEntryId
                                                         delegate: nil
                                                 prepareConfBlock:^(KPPlayerConfig *config) {
                                                     
                                                     [config addConfigKey: @"chromecast.plugin" withValue: @"true"];
                                                     [config addConfigKey: @"chromecast.useKalturaPlayer" withValue: @"true"];
                                                 }];
    }
    
    if (_castProvider == nil) {
        
        self.castProvider = [[KCastProvider alloc] init];
        _castProvider.delegate = self;
        
        [self.view bringSubviewToFront: _castButton];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self playerModerator];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removePlayerFromSuperView];
}

- (void) playerModerator {
    
    [_castProvider startScan: kCCViewControllerCCApplicationId];
}

- (void) removePlayerFromSuperView {
    
    [_castProvider disconnectFromDeviceWithLeave];
    [_kalturaPlayerViewController removePlayer];
    
    [self.kalturaPlayerViewController.view removeFromSuperview];
    [self.kalturaPlayerViewController removeFromParentViewController];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destination = segue.destinationViewController;
    if ([destination isKindOfClass: [CCDevicesViewController class]]) {
        
        CCDevicesViewController *devicesViewController = (CCDevicesViewController *)destination;
        devicesViewController.delegate = self;
        [devicesViewController shouldUpdateWithListOfDevices: [_castProvider devices]];
    }
}

- (IBAction)didClickCastButton:(id)sender {
    
    NSString *ccTitle = @"";
    if (_castProvider.isConnected) {
        
        ccTitle = _castProvider.selectedDevice.routerName;
    } else {
        
        ccTitle = @"Please choose the device.";
    }
    
    UIAlertController *alert =  [UIAlertController
                                  alertControllerWithTitle: ccTitle
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (_castProvider.isConnected) {
        
        UIAlertAction *disconnect = [UIAlertAction actionWithTitle: @"Disconnect"
                                                         style: UIAlertActionStyleDefault 
                                                       handler: ^(UIAlertAction * action) {
                                    
                                                           [_castProvider disconnectFromDeviceWithLeave];
                                                           
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        
        [alert addAction: disconnect];
    } else {
        
        for (KCastDevice *device in _castProvider.devices) {
            
            UIAlertAction *action = [UIAlertAction actionWithTitle: device.routerName
                                                             style: UIAlertActionStyleDefault
                                                           handler: ^(UIAlertAction * action) {
                                                               
                                                               KCastDevice *dev = _devices[[action.title lowercaseString]];
                                                               if (dev != nil) {
                                                                   
                                                                   [self.castProvider connectToDevice: dev];
                                                               }
                                                               
                                                               [alert dismissViewControllerAnimated: YES completion: nil];
                                                           }];
            [alert addAction: action];
        }
    }
    
   
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" 
                                                     style: UIAlertActionStyleDefault 
                                                   handler: ^(UIAlertAction * action) {
                                                       
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma CCDevicesViewControllerDelegate

- (void) devicesViewControler:(CCDevicesViewController *)viewController didSelectDevice: (KCastDevice *)device {
    
    [self.castProvider connectToDevice: device];
}

#pragma mark - KCastProviderDelegate

- (void) castProvider:(KCastProvider *)provider devicesInRange:(BOOL)foundDevices {
    
    self.devices = nil;
    self.devices = [[NSMutableDictionary alloc] init];
    
    for (KCastDevice *device in _castProvider.devices) {
        
        [self.devices setValue: device forKey: [device.routerName lowercaseString]];
    }
    
    _castButton.hidden = !_castProvider.devices.count;
}

- (void) didConnectToDevice:(KCastProvider *)provider {
    
    [_kalturaPlayerViewController initializeCastProvider: _castProvider];
}

@end
