//
//  ViewController.m
//  CCDemo
//
//  Created by Nissim Pardo on 02/06/2016.
//  Copyright © 2016 kaltura. All rights reserved.
//

#import "ViewController.h"
#import "DevicesInRangeViewController.h"


@interface ViewController () <KCastProviderDelegate, DevicesInRangeViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UIView *playerHolderView;
@property (nonatomic, strong) KPViewController *player;
@property (nonatomic, strong) KCastProvider *castProvider;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *castButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _castProvider = [[KCastProvider alloc] init];
    _castProvider.delegate = self;
    [_castProvider startScan:@"48A28189"];
}

- (IBAction)loadPlayer:(UIButton *)sender {
        if (!_player) {
            KPPlayerConfig *config = [[KPPlayerConfig alloc] initWithServer:@"http://cdnapi.kaltura.com"
                                                                   uiConfID:@"31638861"
                                                                  partnerId:@"1831271"];
            config.entryId = @"1_o426d3i4";
            [config addConfigKey:@"chromecast.plugin" withValue:@"true"];
            [config addConfigKey:@"chromecast.useKalturaPlayer" withValue:@"true"];
            [config addConfigKey:@"chromecast.applicationID" withValue:@"48A28189"];
            [config addConfigKey:@"doubleClick.plugin" withValue:@"false"];
//            [config addConfigKey:@"doubleClick.adTagUrl" withValue:@"http://pubads.g.doubleclick.net/gampad/ads?sz=640x360&iu=/6062/iab_vast_samples/skippable&ciu_szs=300x250,728x90&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&correlator=[timestamp]"];
            NSString *adTag = @"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/3274935/preroll&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]";
            [config addConfigKey:@"doubleClick.plugin" withValue: @"true"];
            [config addConfigKey:@"doubleClick.adTagUrl" withValue: adTag];

            _player = [[KPViewController alloc] initWithConfiguration:config];
//            _player.castProvider = _castProvider;
            
            [self addChildViewController:_player];
            _player.view.frame = _playerHolderView.bounds;
            [_player.playerController play];
            [_playerHolderView addSubview:_player.view];
            
            
            [[NSNotificationCenter defaultCenter]   addObserver:self
                                                       selector:@selector(appWillTerminate:)
                                                           name:UIApplicationWillTerminateNotification
                                                         object:[UIApplication sharedApplication]];
        }
}


- (void)appWillTerminate:(NSNotification *)note {
    NSLog(@"terminate");
    if (_player && _player.castProvider) {
        [_player.castProvider disconnectFromDeviceWithLeave];
    }
}


- (UIColor *)defaultTint {
    return [UIColor colorWithRed:0
                           green:122.0 / 255.0
                            blue:1
                           alpha:1];
}

- (IBAction)presentDevice:(UIBarButtonItem *)sender {
    sender.tag = sender.tag ? 0 : 1;
    [self performSegueWithIdentifier:@"PresentDevices" sender:@(sender.tag)];
}
- (IBAction)startCasting:(UIBarButtonItem *)sender {
    sender.tag = sender.tag ? 0 : 1;
    _player.castProvider = sender.tag ? _castProvider : nil;
    sender.tintColor = sender.tag ? [UIColor blackColor] : self.defaultTint;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DevicesInRangeViewController *controller = segue.destinationViewController;
    if ([sender boolValue]) {
        controller.devices = _castProvider.devices;
    } else {
        controller.device = _castProvider.selectedDevice;
    }
    controller.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didSelectDevice:(KCastDevice *)device {
    [_castProvider connectToDevice:device];
}

- (void)disconnect {
    [_castProvider disconnectFromDevice];
}


- (void)castProvider:(KCastProvider *)provider devicesInRange:(BOOL)foundDevices {
    _castButton.enabled = foundDevices;
}

- (void)castProvider:(KCastProvider *)provider didDeviceComeOnline:(KCastDevice *)device {
    
}

- (void)castProvider:(KCastProvider *)provider didDeviceGoOffline:(KCastDevice *)device {
    
}

- (void)didConnectToDevice:(KCastProvider *)provider {
    _castButton.tintColor = [UIColor blackColor];
}

- (void)didDisconnectFromDevice:(KCastProvider *)provider {
    _castButton.tintColor = self.defaultTint;
}

- (void)castProvider:(KCastProvider *)provider didFailToConnectToDevice:(NSError *)error {
    
}
- (void)castProvider:(KCastProvider *)provider didFailToDisconnectFromDevice:(NSError *)error {
    
}

@end
