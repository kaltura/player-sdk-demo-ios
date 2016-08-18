//
//  CCViewController.m
//  KalturaSample
//
//  Created by Vitaliy Rusinov on 7/20/16.
//  Copyright © 2016 Vitaliy Rusinov. All rights reserved.
//

#import "CCViewController.h"
#import "KalturaPlayerViewController.h"

static NSString * const kCCViewControllerUIConfId = @"35815611";
static NSString * const kCCViewControllerPartnerId = @"2164401";
static NSString * const kCCViewControllerCCApplicationId = @"C43947A1";

//static NSString * const kCCViewControllerUIConfId = @"32626752";
//static NSString * const kCCViewControllerPartnerId = @"1982551";
//static NSString * const kCCViewControllerCCApplicationId = @"C43947A1";

//static NSString * const kCCViewControllerUIConfId = @"34339251";
//static NSString * const kCCViewControllerPartnerId = @"2093031";
//static NSString * const kCCViewControllerCCApplicationId = @"C43947A1";


@interface CCViewController () <KCastProviderDelegate>

@property (nonatomic, strong) KalturaPlayerViewController *kalturaPlayerViewController;
@property (nonatomic, strong) KCastProvider *castProvider;

@property (weak, nonatomic) IBOutlet UIButton *castButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

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
                                                     
                                                     NSString *adTagUrl = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
                                                     
                                                     [config addConfigKey:@"doubleClick.adTagUrl" withValue:adTagUrl];
                                                     [config addConfigKey:@"doubleClick.plugin" withValue:@"true"];

                                                 }];
    }
    
    if (_castProvider == nil) {
        
        self.castProvider = [[KCastProvider alloc] init];
        _castProvider.delegate = self;
        
        [self.view bringSubviewToFront: _castButton];
    }
    
    [self.view bringSubviewToFront: _playPauseButton];
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

- (IBAction) didClickPlayPauseButton:(id)sender {
    
    if (_playPauseButton.selected) {
        
        [_kalturaPlayerViewController pause];
    } else {
        
        [_kalturaPlayerViewController play];
    }
    
    _playPauseButton.selected = !_playPauseButton.selected;
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

- (void) didDisconnectFromDevice:(KCastProvider *)provider {
    
    NSLog(@"didDisconnectFromDevice");
}

@end
